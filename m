From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue, 23 Feb 2010 17:56:22 +0100
Subject: lvm and locales memory issue
In-Reply-To: <20100223162842.GC2817@tyan-ft48-01.lab.bos.redhat.com>
References: <4B7D372D.4060608@redhat.com>
	<4B7D4014.3010205@redhat.com>	<4B7EB81D.6090405@redhat.com>	<20100219163008.GR27427@agk-dp.fab.redhat.com>	<4B8262A2.4050408@redhat.com>
	<4B8283B6.7000808@redhat.com>	<20100222181150.GA32020@agk-dp.fab.redhat.com>	<20100222182301.GR2817@tyan-ft48-01.lab.bos.redhat.com>	<4B839743.8020909@redhat.com>
	<4B83F193.9020209@redhat.com>
	<20100223162842.GC2817@tyan-ft48-01.lab.bos.redhat.com>
Message-ID: <4B8408B6.4080303@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 23.2.2010 17:28, Jakub Jelinek wrote:
> On Tue, Feb 23, 2010 at 04:17:39PM +0100, Zdenek Kabelac wrote:
>> It looks like cs_CZ.utf8/LC_MESSAGES/SYS_LC_MESSAGES  is just 59 bytes.
>> There is something seriously wrong with the current glibc optimalization to
>> have 100MB locked into memory if you want to use 59 bytes from this file....
> 
> LC_MESSAGES contains just yesstr/nostr definition, nothing else.
> But guess your application isn't asking just for LC_MESSAGES category...

But that's exactly what we actually need for our lvm.
Translated error messages...

>> Looking at the size of /usr/share/i18n/locales/cs_CZ - one may start to wonder
>> why Czech locales are defining collates for arabic latin and other 'related'
>> laguages, while in German there is simple 'copy "iso14651_t1"'
> 
> iso14651_t1 defines collation for all kinds of charsets, ideally cs_CZ
> should just include that file too and tweak afterwards for the differences
> Czech ordering requires.

And where is the problem to handle that this way ?


>> Another note could be - Ubuntu does not even use locale-archive file and uses
>> locales on per file basis - so now I'm getting curious, where are the tests,
> 
> Not everything Ubuntu does is necessarily a good idea.
> 
>> that proves that Fedora gets some measurable performance advantage?

> 
> Try something trivial, like:
> #include <locale.h>

Yeah - typical real world application...


Anyway all we want to achive here is - to have a choice - if application is
using mlockall() it should be able to select less memory demanding way of
handling locales - whole code is already there and imho needs just a little
tweaking around.

Thus glibc could still handle millions of setlocale switches per second for
typical Fedora user which surely appreciate this worthy optimization for 100MB
disk space - but if the application needs - it should be able to select a
method - which allow only thousands of switches - but will fit into few
hundreds kb of memory space for mlockall().

Zdenek


