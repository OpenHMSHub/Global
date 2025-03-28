import re
import traceback

def verifyEmail(email):
   pattern = "(^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$)"
   if re.match(pattern,email):
      return True
   return False
