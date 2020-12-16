import cherrypy
from os.path import abspath
from cherrypy.process import servers
import os

def app():
    return open("./authoring-interface.html")
app.exposed = True

CP_CONF = {
        '/': {
            'tools.staticdir.on': True,
            'tools.staticdir.dir': abspath('./') # staticdir needs an absolute path
            }
        }

if __name__ == '__main__':
    cherrypy.config.update({'server.socket_port': 49153})
    cherrypy.server.socket_host = os.environ.get('ROS_IP')
    cherrypy.quickstart(app, '/', CP_CONF)
