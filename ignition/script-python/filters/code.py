"""
	Filter tables (and other stuff) live!
	
	
	For example, place a message on a search box with this:
	
		messageType = 'full-text-filter'
		payload = {'key':"", 'value':currentValue.value, 'type':"full_text"}
	
		system.perspective.sendMessage(messageType, payload, scope = 'session' )

	The payload here is meant to be an entry to the filters listing. 
	The message should only allow one filter of each 'key'
	  (So that it can be simply updated - we could layer them, but that gets needlessly complicated.)
"""
# Comment
from java.time import Period,LocalDate,Instant,ZoneId
import re


FILTER_ATTRIBUTES = set(['key', 'value', 'type'])

# Failsafe functions
def NORMALLY_PASS(*args, **kwargs):
	return True

def NORAMLLY_FAIL(*args, **kwargs):
	return False
	

DEFAULT_FILTER = NORMALLY_PASS

#CUSTOM_FILTERS = {
#	None: DEFAULT_FILTER,
#	'': DEFAULT_FILTER,
#	}


def datasetToListDict(dataset):
	"""Converts a dataset into a list of dictionaries. 
	Convenient to treat data on a row-by-row basis naturally in Python.
	
	>>> from shared.tools.examples import simpleDataset
	>>> datasetToListDict(simpleDataset)
	[{'a': 1, 'b': 2, 'c': 3}, {'a': 4, 'b': 5, 'c': 6}, {'a': 7, 'b': 8, 'c': 9}]
	"""
	if not dataset:
		return []
		
	header = [str(name) for name in dataset.getColumnNames()]
	try:
		return [dict(zip(header, row)) for row in zip(*dataset.data)]
	except:
		try:
			possibleGetters = (
				'getDelegateDataset', # Database
				'toIgnitionDataset',  # Sepasoft OEE
				)
			for attr in possibleGetters:
				getter = getattr(dataset, attr, None)
				if getter:
					resolvedDataset = getter()
					break
			else:
				raise RuntimeError("Could not resolve dataset type.")
	
			return [dict(zip(header, row)) for row in zip(*resolvedDataset.data)]
		except:
			return [dict( (columnName, dataset.getValueAt(rix,columnName))
						  for columnName 
						  in header)
					for rix in range(dataset.getRowCount()) ]


PAGE_SANITIZATION_PATTERN = re.compile('[^a-z0-9_]', re.I)

def sanitizePageID(pageid):
	return 'P_' + PAGE_SANITIZATION_PATTERN.sub('_', pageid)

def retrievePageFilters(session_filters, pageid):
	return session_filters.get(sanitizePageID(pageid), [])
	
def clearPageFilters(session_filters, pageid):
	#return session_filters.clear()
	return session_filters
	
#def compareDicts(d1, d2, keys=None):
#	"""
#	Check if the dicts are the same for some keys.
#	Keys are either given or those in common between the two dicts.
#	"""
#	if keys:
#		for key in keys:
#			if d1[key] != d2[key]:
#				return False
#		return True
#	else:
#		for key in (d1.viewkeys() & d2.viewkeys()):
#			if d1[key] != d2[key]:
#				return False
#		return True
	
	
def applyFilters(entry, filter_list=None):
	"""Given an entry dictionary, check if ALL conditional in the filter_list passes."""
	# Note: removed import statement to prevent Jython's import blocking... -ARG
	#system.perspective.print("applyFilters")
	if not filter_list:
		# No filters provided
		#system.perspective.print("No Filter Found")
		return True
		
	# Loop through filter list, collating by key and type
	type_dict = {}
	for condition in filter_list:		
		type_dict.setdefault((condition["key"], condition["type"]), []).append(condition["value"])
	
#		system.util.getLogger('FailFilter').debug('Apply Filter: %r' % (type_dict,))
	
	for (target,filter_type), values in type_dict.items():
		#system.perspective.print("Target: " + str(target))
		# check if the filter has a specialized combinator			
		filter_type,_, combinator = filter_type.partition(':')
		# by default all filters must be true in a specific key and type
		if not combinator:
			combinator = 'all'
		
		# Check if the filter is appropriate
		#   by making sure the target key is actually in the entry (or that all keys work for a full text search)
		if not (target in entry or filter_type == 'full_text'):
			continue
		#system.perspective.print("Filter Type:" + str(filter_type))
		filter_function = getattr(filters, filter_type, DEFAULT_FILTER)
		#system.perspective.print("After getattr" + str(filter_function))		
		# gather the results...
		results = []
		for value in values:
			#system.perspective.print("Entry:" + str(entry))
			#system.perspective.print("Target:" + str(target))
			#system.perspective.print("Value:" + str(value))
			system.perspective.print(filter_function(entry, target, value))
			results.append( filter_function(entry, target, value) )

		if combinator == 'all' and not all(results):
			return False
		elif combinator == 'any' and results and not any(results):
			return False
	
	return True
		

def applyFiltersOnListDict(listDict, filter_list):
	"""Iterate over a list of dictionary, removing rows that fail to match the filter_list conditions."""
	system.util.getLogger('FailFilter').trace('Filtering list dict[%s] with %r' % (len(listDict), filter_list))
	
	return [entry for entry in listDict if filters.applyFilters(entry, filter_list)]
		

def applyFiltersOnDataset(dataset, filter_list):
	"""
	Iterate over a dataset, removing rows that fail to match the filter_list conditions.
	
	Note that the dataset type be super jank. It may or may not be compliant to any assumptions about its api,
	  so we'll just have to assume getRowCount works and hope for the best while RBARing.
	"""
	headings = dataset.getColumnNames()
	
	#system.util.getLogger('FailFilter').trace('Filtering dataset %r with %r' % (dataset, filter_list))
	
	failed_rows = []

	for rix in range(dataset.getRowCount()):
	#for rix, row_dict in enumerate(datasetToListDict(dataset)):
		row_dict = {
			column_name: dataset.getValueAt(rix, column_name)
			for column_name
			in headings
			}
		#system.perspective.print("Apply Filters at row " + str(rix))
		#system.perspective.print(row_dict)
		#system.perspective.print(filter_list)		
		if not applyFilters(row_dict, filter_list):
			failed_rows.append(rix)

	return system.dataset.deleteRows(dataset, failed_rows)

	
	
def conditionsInFilterList(filter_type, key, filter_list):
	"""Returns list of conditions in filter_list matching filter_type and key"""
	return [condition 
			for condition 
			in filter_list 
			if condition['type'] == filter_type 
			  and condition['key'] == key
		   ]
	

###############################################################################
# Filter list manipulation
###############################################################################

def addOntoFilterList(new_filter, filter_list):
	"""
	Given a filter_list of conditions, append in the new_filter.
	Checks for inclusion before adding.
	
	NOTE that this returns a new list and does NOT mutate filter_list!
	
	new_filter must have a schema like:
		{
			'key': 'Some Number Column',
			'type': 'age',
			'value': '>35',
		}
	"""
	assert all(key in new_filter for key in FILTER_ATTRIBUTES), "Filters are dictionaries with the following keys: %r" % FILTER_ATTRIBUTES

	filter_type = new_filter["type"]
	target = new_filter["key"]
	value  = new_filter["value"]
	
	included = False
 	for condition in filter_list:
		if (not included and condition['type'] == filter_type 
						 and condition['key'] == target 
						 and condition['value'] == value):
			included = True
			break
	
	if not included:
		return [condition for condition in filter_list] + [new_filter]
	else:
		return [condition for condition in filter_list]


def mergeIntoFilterList(new_filter, filter_list):
	"""
	Given a filter_list of conditions, merge in the new_filter.
	Overrides all matching entries if key and type is the same.

	NOTE that this returns a new list and does NOT mutate filter_list!

	new_filter must have a schema like:
		{
			'key': 'Some Number Column',
			'type': 'age',
			'value': '>35',
		}
	"""
	assert all(key in new_filter for key in FILTER_ATTRIBUTES), "Filters are dictionaries with the following keys: %r" % FILTER_ATTRIBUTES

	filter_type = new_filter["type"]
	target = new_filter["key"]
	value  = new_filter["value"]
 	
 	updated_filter_list = []

 	merged = False # keep track so this is one-and-only-one addition
 	for condition in filter_list:
 		if condition['type'] == filter_type and condition['key'] == target:
 			# skip duplicate conditionals, if any
 		 	if merged:
	 			continue
 			
 			updated_filter_list.append(new_filter)
 			merged = True	 		
 		else:
 			updated_filter_list.append(condition)

 	# if we have looped over the whole list and still haven't merged, add it now
	if not merged:
		updated_filter_list.append(new_filter)
 	
 	return updated_filter_list
	
	
def removeFromFilterList(old_filter, filter_list):
	"""
	Given a filter_list of conditions, remove all entries like old_filter.
	
	NOTE that this returns a new list and does NOT mutate filter_list!
	
	old_filter must have a schema like:
		{
			'key': 'Some Number Column',
			'type': 'age',
			'value': '>35' # optional!
		}
	If a value is included, then only that specific filter will be removed.
	If a value is omitted, it will remove ALL filters of that type.
	"""
	assert all(key in old_filter for key in FILTER_ATTRIBUTES), "Filters are dictionaries with the following keys: %r" % FILTER_ATTRIBUTES

	filter_type = old_filter["type"]
	target = old_filter["key"]
	value  = old_filter.get("value", None)
		
	updated_filter_list = []

	for condition in filter_list:
		if all((condition['type'] == filter_type,
			    condition['key'] == target,
			    # skip including if no value is provide or a match is found
			    value is None or condition['value'] == value)):
			continue
		else:
			updated_filter_list.append(condition)

	return updated_filter_list	



###############################################################################
# Filter list management
###############################################################################

FILTER_MANAGEMENT_DISPATCH = {
	'remove': removeFromFilterList,
	'merge': mergeIntoFilterList,
	'add': addOntoFilterList,
	None: lambda filter_list: [entry for entry in filter_list]
	}
 
def sqlescape(value):
	replaceChars = {
		"\0": "\\0",
		"\r": "\\r",
		"\x08": "\\b",
		"\x09": "\\t",
		"\x1a": "\\z",
		"\n": "\\n",
		"\r": "\\r",
		"\"": "\\\"",
		"'": "\\'",
		"\\": "\\\\",
		"%": "\\%"
	}
	for replaceChar in replaceChars:
		value = value.replace(replaceChar, replaceChars[replaceChar])
	return value

def updateFilterList(session, pageId, filter_type, filter_key, filter_column_name, filter_value):
	"""
	A general purpose filter manipulator.
		  updates session filters given the payload's instruction.
	"""
	
	if pageId in session.custom.filters and filter_key in session.custom.filters[pageId]:
		where = "1=1"
		if filter_type == "match":
			# Output "(column) LIKE (value) %" to the SQL where clause
			if filter_value != None and filter_value != "":
				filter_value_str = sqlescape(str(filter_value))
				if str(type(filter_column_name)) in ["<type 'array.array'>", "<type 'com.inductiveautomation.perspective.gateway.script.PropertyTreeScriptWrapper$ArrayWrapper'>"]:
					whereCols = []
					for col in filter_column_name:
						whereCols.append("%s LIKE '%s%%'" % (col, filter_value_str))
					where = "(%s)" % (" OR ".join(whereCols))
				else:
					where = "%s LIKE '%s%%'" % (filter_column_name, filter_value_str)
		elif filter_type == "like":
			# Output "(column) LIKE  % (value) %" to the SQL where clause
			if filter_value != None and filter_value != "":
				filter_value_str = sqlescape(str(filter_value))
				if str(type(filter_column_name)) in ["<type 'array.array'>", "<type 'com.inductiveautomation.perspective.gateway.script.PropertyTreeScriptWrapper$ArrayWrapper'>"]:
					whereCols = []
					for col in filter_column_name:
						whereCols.append("%s LIKE '%%%s%%'" % (col, filter_value_str))
					where = "(%s)" % (" OR ".join(whereCols))
				else:
					where = "%s LIKE '%%%s%%'" % (filter_column_name, filter_value_str)
		elif filter_type == "equals":
			# If array of values then output "(column) IN (value1, value2, value3...)" to the SQL where clause. Good for multi-select dropdown
			# If single value then output "column = value"
			if filter_value != None:
				if str(type(filter_value)) in ["<type 'array.array'>", "<type 'com.inductiveautomation.perspective.gateway.script.PropertyTreeScriptWrapper$ArrayWrapper'>"]:
					filter_value_str = "IN (%s)" % (",".join([str(val.value) for val in filter_value]))
				else:
					filter_value_str = "= %s" % str(filter_value)
					
				if str(type(filter_column_name)) in ["<type 'array.array'>", "<type 'com.inductiveautomation.perspective.gateway.script.PropertyTreeScriptWrapper$ArrayWrapper'>"]:
					whereCols = []
					for col in filter_column_name:
						whereCols.append("%s %s" % (col, filter_value_str))
					where = "(%s)" % (" OR ".join(whereCols))
				else:
					where = "%s %s" % (filter_column_name, filter_value_str)
		elif filter_type == "singleYear":
			# Output "(column) BETWEEN (value1)-01-01 00:00:00 AND (value2)-12-31 23:59:59" to the SQL where clause. Good for single dropdown year selection
			if filter_value != None:
				if str(type(filter_value)) in ["<type 'array.array'>", "<type 'com.inductiveautomation.perspective.gateway.script.PropertyTreeScriptWrapper$ArrayWrapper'>"]:
					filter_value_objs = []
					for val in filter_value:
						startYear = "%s-01-01 00:00:00" % val
						endYear = "%s-12-31 23:59:59" % val
						filter_value_objs.append("BETWEEN '%s' AND '%s'" % (startYear, endYear))
					
					filter_value_str = "(%s)" % (" OR ".join(filter_value_objs))
				else:
					startYear = "%s-01-01 00:00:00" % filter_value
					endYear = "%s-12-31 23:59:59" % filter_value
					filter_value_str = "BETWEEN '%s' AND '%s'" % (startYear, endYear)
					
				where = "%s %s" % (filter_column_name, filter_value_str)
		elif filter_type == "dateRange":
			# Input is a list of two dates, Output date range selection
			if filter_value != None:
				if str(type(filter_value)) in ["<type 'list'>"]:
					#filter_value_objs = []
					#for val in filter_value:
					startDate = "%s" % system.date.format(filter_value[0],'yyyy-MM-dd')
					endDate = "%s" % system.date.format(filter_value[1],'yyyy-MM-dd')
					filter_value_str = "BETWEEN '%s' AND '%s'" % (startDate, endDate)
					
					#filter_value_str = "(%s)" % (" OR ".join(filter_value_objs))
					where = "%s %s" % (filter_column_name, filter_value_str)
				else:
					where = '1=1'
		elif filter_type == "date_lowerBound":
			# Input is a list of two dates, Output is selected date should less than start and end date
			if filter_value != None:
				if str(type(filter_value)) in ["<type 'list'>"]:
					#filter_value_objs = []
					#for val in filter_value:
					startDate = "%s" % system.date.format(filter_value[0],'yyyy-MM-dd')
					endDate = "%s" % system.date.format(filter_value[1],'yyyy-MM-dd')
					where = "%s<='%s'" % (filter_column_name, endDate)
				else:
					where = '1=1'
		elif filter_type == "date_upperBound":
			# Input is a list of two dates, Output is selected date should greater than start and end date
			if filter_value != None:
				if str(type(filter_value)) in ["<type 'list'>"]:
					#filter_value_objs = []
					#for val in filter_value:
					startDate = "%s" % system.date.format(filter_value[0],'yyyy-MM-dd')
					endDate = "%s" % system.date.format(filter_value[1],'yyyy-MM-dd')
					where = "'%s'>='%s' AND '%s'>='%s'" % (filter_column_name, startDate, filter_column_name, endDate)
				else:
					where = '1=1'

		elif filter_type == "notEqual":
			# Output "(column) != (value)"
			if filter_value != None:
				filter_value_str = "!= %s" % str(filter_value)
				where = "%s %s" % (filter_column_name, filter_value_str)
		elif filter_type == "notEqualOrNull":
			# Output "(column) != (value) or (column) is Null"
			if filter_value != None:
				filter_value_str = "!= %s" % str(filter_value)
				where = "%s %s" % (filter_column_name, filter_value_str)
				where += " or %s %s" % (filter_column_name, 'is Null')
		elif filter_type == "lowerBoundInclusive":
			# Output "(column) != (value)"
			if filter_value != None:
				filter_value_str = ">= %s" % int(filter_value)
				where = "%s %s" % (filter_column_name, filter_value_str)
		elif filter_type == "upperBoundInclusive":
			# Output "(column) != (value)"
			if filter_value != None:
				filter_value_str = "<= %s" % int(filter_value)
				where = "%s %s" % (filter_column_name, filter_value_str)
		elif filter_type == "beforeAfter":
			# Output "(column) != (value)"
			if filter_value != None:
				today = system.date.format(system.date.now(), "yyyyMMdd")
				if filter_value == 'before':
					filter_value_str = "%s" % today
					where = "%s <= '%s'" % (filter_column_name, filter_value_str)
				elif filter_value == 'after':
					filter_value_str = "%s" % today
					where = "%s >= '%s'" % (filter_column_name, filter_value_str)
		elif filter_type == "nullOrNotNull":
			# Output "(column) != (value)"
			if filter_value != None:
				if filter_value == 'isNull':
					where = " %s %s" % (filter_column_name, 'is Null')
				elif filter_value == 'isNotNull':
					where = " %s %s" % (filter_column_name, 'is not Null')
		elif filter_type == "mask":
			# Output "(column) != (value)"
			if filter_value != None:
				where = " %s %s %s %s" % (filter_column_name, '&', filter_value, '<>0')
		elif filter_type == "passthrough":
			# Output "(column) != (value)"
			if filter_value != None:
				where = filter_value
		
		session.custom.filters[pageId][filter_key]["where"] = where
		session.custom.filters[pageId][filter_key]["value"] = filter_value
	
def manageFilterList(filter_list, filter_type, filter_key, filter_value, action='auto'):
	"""
	A general purpose filter manipulator.
		  returns a new filter list given the payload's instruction and a filter list.
	"""
	entry = {
		'type': filter_type,
		'key': filter_key,
		'value': filter_value
	}
	
	# If a blank filter is provided (guess by falsiness), then merge or remove.
	if action == 'auto':
		if entry['value']:
			action = 'merge'
		else:
			action = 'remove'
	
	return FILTER_MANAGEMENT_DISPATCH[action](entry, filter_list)


###############################################################################
# Message handlers
###############################################################################

def messageHandler_respondWithActiveFilters(payload, filter_list):
	"""
	The 'active-filters' message handler;
	  format a response for an active filters request.
	
	Use this in the body of 
	  on a component that can pass in a filter listing:
	  
	  filters.messageHandler_requestActiveFilters(payload, self.custom.filters)
	"""
	filter_type = payload['filter']['type']
	filter_key  = payload['filter']['key']
	
	filtered_list = []
	for condition in filter_list:
		if (condition['type'] == filter_type and condition['key']  == filter_key):
		    filtered_list.append(condition)
	
	response = {
		'filters': filtered_list
		}
	
	system.perspective.sendMessage('reply: active-filters', response, scope ='page')
	

def queryActiveFilters(filter_type, key):
	payload = {
		'filter': {
			'type': filter_type,
			'key': key,
			}
		}

	system.perspective.sendMessage('active-filters', payload, scope ='page')
	
	
def messageHandler_UpdateFilter(payload, filter_list):
	"""
	The 'update-filters' message handler;
	  returns a new filter list given the payload's instruction and a filter list.
	
	The 'action' payload key determines how the new filter is applied to the list.
	"""
	action = payload['action']
	entry = payload['filter']
	
	# If a blank filter is provided (guess by falsiness), then merge or remove.
	if action == 'auto':
		if entry['value']:
			action = 'merge'
		else:
			action = 'remove'
	
	return FILTER_MANAGEMENT_DISPATCH[action](entry, filter_list)


def updateFilterListeners(action, filter_type, key, value=None):
	"""Package and send an update to any components listing for filtering messages."""
	messageType = 'update-filters'
	payload = {
		'action': action,
		'filter': {
			'key': key, 
			'value':value, 
			'type': filter_type},
		}
	system.perspective.sendMessage(messageType, payload, scope ='page')


###############################################################################
# Helper functions
###############################################################################

def numeric(number,filt):
	if '-' in filt:
		ll,ul = filt.split('-')
		return float(ll)<number<float(ul)
	elif filt[0] == '>=':
		return number>=float(filt[1:])
	elif filt[0] == '<=':
		return number<=float(filt[1:])
	elif filt[0] == '>':
		return number>float(filt[2:])
	elif filt[0] == '<':
		return number<float(filt[2:])
	else:
		return True
		
		
###############################################################################
# Custom filters
###############################################################################
#_local_scope_start = set(key for key in locals())


def boolean(row, key, filt):
	if not key in row: 
		return True

	value = row.get(key, None)
	
	if filt in (True, 1, 'true', '1'):
		# We'll check literals, strings, and then chars
		if value in (True, 1):
			return True
		elif str(value).strip().lower() in ('true', '1', 'yes'):
			return True
		elif value and str(value).strip().lower()[0] in ('t','y', '1'):
			return True
		else:
			try:
				return value > 0
			except:
				return False
	if filt in (False, 0, 'false', '', '0'):
		# We'll check literals, strings, and then chars
		if value in (False, None, 0, ''):
			return True
		elif str(value).strip().lower() in ('', 'false', 'no', 'null', 'none'):
			return True
		elif value and str(value).strip().lower()[0] in ('f', 'n', 'o', '0', ' '):
			return True		
		return False
	
	return True


def age(row,key,filt):
	if not key in row: 
		return True

	dob = row[key]
	if dob is not None:
		dob = Instant.ofEpochMilli(dob.time).atZone(ZoneId.systemDefault()).toLocalDate()
		now = LocalDate.now()
		number = (now.year - dob.year)
		doy1, doy2 = dob.getDayOfYear(),now.getDayOfYear()
		if doy1 < doy2:
			number -= (doy1-doy2)/365.0
		else:
			number += (365.24-doy1+doy2)/365.24
#		print("dob {}, age {}, filter {},result {}".format(dob,number,filt,numeric(number,filt)))
		return numeric(number,filt)
	return False
			
		
def gender(row,key,filt):
	if not key in row: 
		return True
	
	if not (filt and row[key]):
		return False
		
	f = filt.lower()[0]
	r = row[key].strip().lower()[0]
	
	if f == 'f':
		return r == 'f'
	elif f == 'm':
		return r == 'm'
	elif f == 'o':
		return r not in ('f','m')
	else:
		return False
	
	
def full_text(row,key,filt):
	t = "\t".join([str(row[key]) for key in row]).lower()
	return filt.lower() in t
	
def like(row,key,filt):
		#if isinstance(filt, (str, unicode)):
		t = str(row.get(key, '')).lower()
		return str(filt.lower()) in t
	
def match(row, key, filt):
	if isinstance(filt, (str, unicode)):
		#return str(row.get(key, '')) == filt
		return not str(row.get(key, '')).find(filt)
	else:
		return row.get(key, '') in filt

def date(row,key,filt):
	#The assumption is the date comes in a yyyy-mm-dd
	t = str(row.get(key, '')).lower()
	db_date = t.replace('-', '')
	date = str(db_date[4:8]) + str(db_date[0:4])
	#Strip slashes and dashes
	f = str(filt.replace("/",""))
	filter = f.replace("-","")
	#system.perspective.print(db_date)
	#system.perspective.print(date)
	#system.perspective.print(filter)
	return str(filter.lower()) in date

def minBound(row, key, filt):
	if not key in row: 
		return True
	return filt <= row[key]
	
	
def maxBound(row, key, filt):
	if not key in row: 
		return True
	return row[key] <= filt

	
def isAlex(row,key,filt):
	if not key in row: 
		return True
	if key in row:
		fname = row[key]
		return fname == "Alex"
		

################################################################################	
## End custom filters
#_local_scope_end = set(key for key in locals())
#
## Add new functions to the global dictionary
#for _custom_name in (_local_scope_end - _local_scope_start):
#	CUSTOM_FILTERS[_custom_name] = locals()[_custom_name]
