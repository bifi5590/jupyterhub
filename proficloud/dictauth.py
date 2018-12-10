from tornado import gen
from IPython.utils.traitlets import Dict
from jupyterhub.auth import Authenticator

class DictionaryAuthenticator(Authenticator):

    users = { "alex" : "pxce" }
    
    @gen.coroutine
    def authenticate(self, handler, data):
        if self.users.get(data['username']) == data['password']:
            return data['username']