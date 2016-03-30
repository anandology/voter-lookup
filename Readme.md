Voter Lookup
============

Voter Lookup is an application that finds the state, assembly constituency and polling booth, given an voter id.

This works by maintaining the all the voterids in a sqlite database table.

USAGE
-----

To start development server:

	$ python webapp.py

The program expects a SQLite database with name `voter-lookup.db` in the current directory. A different database file can be specified using the environment variable `VOTER_LOOKUP_DATABSE`.

	$ VOTER_LOOKUP_DATABSE=a.db python webapp.py

Running in production:

	$ gunicorn webapp:application -b 127.0.0.1:8080

Running using Docker
--------------------

Build the docker image:

	$ docker build anandology/voter-lookup:devel .

Run the application:

	$ docker run -p 8080:80 -v /opt/voter-lookup/voter.db:/voter.db anandology/voter-lookup:devel

This assumes the voterids database is available at /opt/voter-lookup/voter.db.

Use option `--restart=always` if you want docker to auto-restart your application and auto start it on boot.

API
---

	$ curl 'http://voter-lookup/search?voterid=ABC1234567'
	[
	 {
	  "voterid": "ABC1234567",
	  "state": "DL",
	  "ac": 56
	  "pb": 130,
	 }
	]

Optionally, two-letter state code can be specified to limit the search to one particular state.


	$ curl 'http://voter-lookup/search?voterid=ABC1234567&state=DL'
	[
	 {
	  "voterid": "ABC1234567",
	  "state": "DL",
	  "ac": 56
	  "pb": 130,
	 }
	]

Please note that the `voter-lookup` in the URL should be replaced with the hostname.

Data Format
-----------

The database is usually created from a data file, typically named like `voter-lookup-dl-20160301.tsv.gz`. The last two parts in the filename before the extension are two letter state code and timestamp.

The file is a tabular file separated by tabs and contain the following columns.

* two-letter state code in upper case (eg. DL, KA etc.)
* assemby constituency number
* polling booth number
* voterid

The file should not have any headers.

Building the database
---------------------

Since the above mentioned file format is same as the database schema, we can import the file directly into the database.

To start with, create a database and load the schema.

	$ sqlite3 voter-lookup.db < schema.sql

And the import the data.

	$ sqlite3 voter-lookup.db -cmd '.separator "\t"' '.import "voter-lookup-dl-20160301.tsv" voter'

Please note that you'll have to deflate the gz file before importing.

Usually it is more comfortable to split the file into multiple parts each with about a million lines or so and load each one.

	$ mkdir parts
	$ zcat voter-lookup-dl-20160301.tsv.gz | split -l 1000000 - parts/part-

	$ for f in parts/*; do echo $f; sqlite3 voter-lookup.db -cmd '.separator "\t"' ".import '$f' voter"; done
