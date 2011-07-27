import sys
import pycurl
try:
     from cStringIO import StringIO
except ImportError:
     from StringIO import StringIO

body = StringIO()
c = pycurl.Curl()
c.setopt(c.URL, 'http://savannah.gnu.org/maintenance/FrontPage/pageIds')
c.setopt(c.WRITEFUNCTION, body.write)
c.perform()
c.close()

contents = body.getvalue()
# TODO: how to easily parse a string as a tuple, without using eval()
# and opening a security hole big enough for my lazyness to go
# through?
list = eval(contents)

for i in list:
  f = open("zwiki-export/%s" % i, "wb")
  curl = pycurl.Curl()
  curl.setopt(pycurl.URL, "http://savannah.gnu.org/maintenance/%s/src" % i)
  curl.setopt(pycurl.WRITEDATA, f)
  curl.perform()
  curl.close()
  sys.stdout.write(".")
  sys.stdout.flush()

