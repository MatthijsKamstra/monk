# Neko Web Server

We will use a rarely mentioned feature from Haxe.

You can run a web-server : Neko Web Server

And the cool part is: You don't have to install anything if you already have Haxe installed.

```bash
Neko Web Server v1.0 - (c)2006-2013 Haxe Foundation
	Options :
		-p <port> : change server port
		-h <host> : change server host
		-d <dir> : change the server base directory
		-log <file> : set log file
		-rewrite : activate pseudo mod-rewrite for smart urls
```

You need the path to your files (so replace `path/to/files` with your own path) example: `path/to/files/haxejs/07pixi/code/bin/`

```bash
nekotools server -p 2000 -h localhost -d path/to/files
```

and open your browser to <http://localhost:2000>

You can also start the web-server with it's defaults (port:2000, host:localhost)

```bash
nekotools server
```

But then you have to visit the configure-page the server by going to <http://localhost:2000/server:config>

(or open your terminal in the correct folder)

Read more about Neko tools:

- <http://blog.presidentbeef.com/neko_tutorial/tools.html#nekotools>
- <http://old.haxe.org/doc/start/neko>