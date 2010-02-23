From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue, 23 Feb 2010 16:17:39 +0100
Subject: lvm and locales memory issue
In-Reply-To: <4B839743.8020909@redhat.com>
References: <4B7D063A.7070601@redhat.com>	<4B7D372D.4060608@redhat.com>	<4B7D4014.3010205@redhat.com>	<4B7EB81D.6090405@redhat.com>	<20100219163008.GR27427@agk-dp.fab.redhat.com>	<4B8262A2.4050408@redhat.com>	<4B8283B6.7000808@redhat.com>	<20100222181150.GA32020@agk-dp.fab.redhat.com>	<20100222182301.GR2817@tyan-ft48-01.lab.bos.redhat.com>
	<4B839743.8020909@redhat.com>
Message-ID: <4B83F193.9020209@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 23.2.2010 09:52, Zdenek Kabelac wrote:
> On 22.2.2010 19:23, Jakub Jelinek wrote:
>> On Mon, Feb 22, 2010 at 06:11:50PM +0000, Alasdair G Kergon wrote:
>>> On Mon, Feb 22, 2010 at 02:16:38PM +0100, Zdenek Kabelac wrote:
>>>> On 22.2.2010 11:55, Zdenek Kabelac wrote:
>>>>> 'rm -f /usr/lib/locale/locale-archive'
>>>>> 'localedef -f UTF-8 -i cs_CZ /usr/lib/locale/cs_CZ.utf8'
>>>>> 'localedef -i cs_CZ -c -f UTF-8 -A /usr/share/locale/locale.alias cs_CZ.UTF-8'
>>>
>>> %attr(0644,root,root) %verify(not md5 size mtime mode) %ghost %config(missingok,noreplace) %{_prefix}/lib/locale/locale-archive
>>>
>>> So removing/changing that file is a fully-supported process?
>>
>> Of course not.  The reason it has these flags is for glibc upgrading
>> purposes.  glibc-common rpm ships with locale-archive.tmpl file, and %post
>> merges all locales from that file with any possible user added locales in
>> locale-archive into a new locale-archive, the *.tmpl file is then deleted.
>>
>>> Perhaps anaconda should automatically remove it (if it has not been customised) on
>>> any system with < 640MB RAM?
>>
>> If you delete the file, you loose all localization, because we don't ship
>> the individual /usr/lib/locale/*_*/* locale files for space reasons.
>> The same effect as if you don't call setlocale at all, or just with "C" in
>> all apps.
>>
> 
> 
> Ok - and now I'm getting confused and lost here.
> 
>>From our chat I've got impression that using 'localedef' is perfectly valid
> way how to create usable content for /usr/lib/locale.
> 
> On my Fedora Rawhide system I've /usr/share/i18n/locales 6MB and
> /usr/share/locale/cs 12MB, that contains amongst other things 128KB libc.mo
> file and a lot of other files.
> 
>>From my simple test program I do get valid Czech locale error messages and
> properly localized strftime() output from glibc calls in the case I recreate
> /usr/lib/local/locale-archive with 'localedef' command above.
> 
> So what is the purpose of /usr/share/i18n/local, /usr/share/locale in this case?
> 
> What do I miss in case the local-archive.tmpl file is not in used?
> 
> Is the Czech locale special and there are some some other locales which could
> not be easily recreated?
> 
> (btw it takes 1.3sec to create 1 Czech locale-archive, thus it looks like for
> 200 locales it could take maybe 4minutes in case of complete full recreate of
> the locale-archive file)
> 
> It seems to me that my glibc-commons contains all files needed to create
> usable locale-archive even without locale-archive.tmpl - am I missing
> something here?
> 
>>From strace it looks like only the content of /usr/share/i18n/locales does
> matter and it translates files in string form to binary form.
> Files from /usr/share/locale are opened runtime when needed by application.
> 
> Thus I'm quite curios why the file  /usr/lib/locale/locale-archive is actually
> opened for the case that only  LC_MESSAGES is set to some locales.
> IMHO for this only files form /usr/share/locale should matter -  I could
> assume it's because of the aliasing handling which is also hidden inside
> cached binary files - but it's pretty overkill isn't?

It looks like cs_CZ.utf8/LC_MESSAGES/SYS_LC_MESSAGES  is just 59 bytes.
There is something seriously wrong with the current glibc optimalization to
have 100MB locked into memory if you want to use 59 bytes from this file....

Few more comments:

local-archive for cs_CZ.utf8 is:          ~475kb   (with 100kb hole inside)
however files in cs_CZ.utf8 have in total ~372kb
when we add german de_DE.utf8 locale - the sum of local-archive basically
follows the increase size in from cs_CZ.utf8  & de_DE.utf8 put together - no
sharing of a single information.

Looking at the size of /usr/share/i18n/locales/cs_CZ - one may start to wonder
why Czech locales are defining collates for arabic latin and other 'related'
laguages, while in German there is simple 'copy "iso14651_t1"'

Another note could be - Ubuntu does not even use locale-archive file and uses
locales on per file basis - so now I'm getting curious, where are the tests,
that proves that Fedora gets some measurable performance advantage?
(you would probably need 24000 page entries to create mmap table for whole
100MB file... and if only specific portions of this large file are mapped,
than it's quite simple to switch these to malloc/read code when user set some
flag...

Zdenek


