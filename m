From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Mon, 22 Feb 2010 14:16:38 +0100
Subject: lvm and locales memory issue
In-Reply-To: <4B8262A2.4050408@redhat.com>
References: <4B7D063A.7070601@redhat.com>	<4B7D372D.4060608@redhat.com>	<4B7D4014.3010205@redhat.com>	<4B7EB81D.6090405@redhat.com>	<20100219163008.GR27427@agk-dp.fab.redhat.com>
	<4B8262A2.4050408@redhat.com>
Message-ID: <4B8283B6.7000808@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 22.2.2010 11:55, Zdenek Kabelac wrote:
> On 19.2.2010 17:30, Alasdair G Kergon wrote:
>> On Fri, Feb 19, 2010 at 05:11:09PM +0100, Zdenek Kabelac wrote:
>>> Jakub suggest solution to use  a tiny small forked() process with very limited
>>> funcionality to handle mlockall() task  without any usage of locales.
>>
>> Nack.  It's not tiny - it's most of the code - and it's a *state* of usage of
>> the code - a way of using the *same* code as we also use without mlockall at
>> other times - the code knows to behave slightly differently depending whether
>> or not it is in this state.
>>
>> Surely most people don't need most of the locales - they should be able to
>> choose which ones to cache in the archive file - the ones they regularly use -
>> and take the performance hit on the occasions (if any) they want to use the
>> non-cached ones.
>>
>> I notice the code to build the archive is in a 'fedora' subdir in the spec file
>> with hard-coded pathnames.  Is there an 'upstream' approach here or do different
>> distributions handle this differently and if so why?
>>
>>> Eventually error reports, debugs and other things should be handled in
>>> surrounding environment - just like we have discussed already as a one
>>> potential solution.
>>  
>> Opposite way around.  The hack would be to push all the things that attempt to
>> access that locale archive file out into a subprocess.  That would first require
>> an audit of all the the glibc functions we use to determine which ones can attempt
>> to access that file.  Then we'd have to place wrappers around those functions 
>> to push them into a subprocess and avoid using them synchronously when in this
>> 'mlocked' 
> 
> state.
>>
> 
> Here is outcome of another chat with Jakub:
> 
> It looks like there is no easy way to modify API of glibc anytime soon in the
> near future and this change would have to go through Uli first...
> (there seems to be things like 'newlocale()' which make things more complicated)
> 
> As the workaround for 'memory-limited' environments here is suggested  workadound.
> 
> remove cache file:
> 'rm -f /usr/lib/locale/locale-archive'
> 
> and create just locales you need to use:
> 'localedef -f UTF-8 -i cs_CZ /usr/lib/locale/cs_CZ.utf8'
> (In this case small separate files in the directory:
> "/usr/lib/locale/cs_CZ.utf8"  are create and opened during application runtime
> - this is probably less effiecient then this second way:
> 
> or eventually recreate /usr/lib/locale/locale-archive with this command:
> 'localedef -i cs_CZ -c -f UTF-8 -A /usr/share/locale/locale.alias cs_CZ.UTF-8'
> (In this case only .5MB file is generated - for adding another locales - just
> another call with localedef is needed - i.e. en_US, de_DE, cs_CZ will lead to
> ~3MB files at my current installation.
> 
> Memory footprint for just cs_CZ test case is - i.e. main() { setlocale();
> mloockall{} } is approximately 4MB - compared to 100MB with normal - full
> locale-archive.
> 

To initiate some solution for our anaconda problems after some discussion with
anaconda team member I've created this bugzilla (as he wished)

https://bugzilla.redhat.com/show_bug.cgi?id=567252

Zdenek


