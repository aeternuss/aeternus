# Linux - Specifying the Time Zone with TZ

In POSIX systems, a user can specify the time zone by means of the TZ
environment variable.

## TZ format

In POSIX.1 systems the value of the TZ variable can be in one of three formats.

The third format looks like this:

`:characters`

In the GNU C Library, characters is the name of a file which describes the time zone.

If the TZ environment variable does not have a value, the operation
chooses a time zone by default.

In the GNU C Library, the default time zone is like the specification
`TZ=:/etc/localtime` (or `TZ=:/usr/local/etc/localtime`, depending on
how the GNU C Library was configured; see Installation).

If characters begins with a slash, it is an absolute file name;
otherwise the library looks for the file /usr/share/zoneinfo/characters.

The zoneinfo directory contains data files describing local time zones
in many different parts of the world. The names represent major cities,
with subdirectories for geographical areas; for example,
America/New_York, Europe/London, Asia/Hong_Kong. These data files are
installed by the system administrator, who also sets /etc/localtime to
point to the data file for the local time zone.
