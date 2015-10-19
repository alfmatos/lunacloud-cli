# lunacloud-cli
Lunacloud hosting [API](https://www.lunacloud.com/docs/tech/compute-restful-api.pdf) command line interface.

*lunacloud-cli* is a very simple tool to automate some processes of starting and stopping instances running on [Lunacloud](http://lunacloud.com).

## Examples

```
$ lunacloud-cli list # lists all available virtual enviroments
$ lunacloud-cli status server_name # shows status and specs of a server
$ lunacloud-cli start server_name # starts server_name
$ lunacloud-cli stop server_name # Stops server_name
```

## Authentication

The Lunacloud API requires HTTP authentication in the form of a *API Token*.

The Token is available on your Lunacloud account, in the control panel under the menu `<your email>` >> `My Settings` >> `API (tab)`. There is a string "Basic c3VwcG9ydEBtZXRyaWZseS5jb206cmlja3JvbGxlZDgy". Just copy the token and use it as an option or an enviroment variable:

```
 $ export LUNACLOUD_TOKEN="c3VwcG9ydEBtZXRyaWZseS5jb206cmlja3JvbGxlZDgy"
 $ lunacloud-cli [...]
```

Alternatively, pass it in as an argument (list example bellow):

```
 $ luacloud-cli -t "c3VwcG9ydEBtZXRyaWZseS5jb206cmlja3JvbGxlZDgy" list
```

Up until recently username and password were allowed. You can try using this as a fallback auhtentication mechanism. The command line tool accepts environment variables or runtime arguments:

**Environment variables:** set `LUNACLOUD_USERNAME` and  `LUNACLOUD_PASSWORD` with your credentials, and the script will pick it up.

**Command line:** pass in  `-u username` and `-p password`. If no password is given, the tool will prompt for one (breaking any automated scripts).

## Install

The tool has a few gem requirements: nokogiri, for xml parsing, and highline for user input handling. To install the required dependencies just run the command bellow:

```
$ gem install nokogiri highline
```

## Notes

Some issues encountered:

* https doesn't seem to be working at the moment
* API calls only work with master accounts and not delegates
* Still no support for creating and deleting instances from *lunacloud-cli*

*This script is in no way affiliated with Lunacloud. It is not an official tool, nor is it developed by anyone with affiliation or relationship with Lunacloud.*
