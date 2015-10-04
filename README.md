# lunacloud-cli
Lunacloud hosting API command line interface.

*lunacloud-cli* is a very simple tool to automate some processes of starting and stopping instances running on [Lunacloud](http://lunacloud.com).

## Examples

```
$ lunacloud-cli list # lists all available virtual enviroments
$ lunacloud-cli status server_name # shows status and specs of a server
$ lunacloud-cli start server_name # starts server_name
$ lunacloud-cli stop server_name # Stops server_name
```

## Authentication

The Lunacloud API requires basic HTTP authentication in the form of username and password. The command line tool accepts environment variables or runtime arguments:

**Environment variables:** set `LUNACLOUD_USERNAME` and  `LUNACLOUD_PASSWORD` with your credentials, and the script will pick it up.

**Command line:** pass in  `-u username` and `-p password`. If no password is given, the tool will prompt for one (breaking any automated scripts).

## Notes

Some issues encountered:

* https doesn't seem to be working
* API calls only work with master accounts and not delegates
* Still no support for creating and deleting instances from *lunacloud-cli*

*This script is in no way affiliated with Lunacloud. It is not an official tool, nor is it developed by anyone with affiliation or relationship with Lunacloud.*


