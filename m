From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue, 23 Feb 2010 10:14:55 +0100
Subject: lvm and locales memory issue
In-Reply-To: <20100223091539.GV2817@tyan-ft48-01.lab.bos.redhat.com>
References: <4B7D063A.7070601@redhat.com>
	<4B7D372D.4060608@redhat.com>	<4B7D4014.3010205@redhat.com>
	<4B7EB81D.6090405@redhat.com>	<20100219163008.GR27427@agk-dp.fab.redhat.com>	<4B8262A2.4050408@redhat.com>
	<4B8283B6.7000808@redhat.com>	<20100222181150.GA32020@agk-dp.fab.redhat.com>	<20100222182301.GR2817@tyan-ft48-01.lab.bos.redhat.com>	<4B839743.8020909@redhat.com>
	<20100223091539.GV2817@tyan-ft48-01.lab.bos.redhat.com>
Message-ID: <4B839C8F.5030103@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 23.2.2010 10:15, Jakub Jelinek wrote:
> On Tue, Feb 23, 2010 at 09:52:19AM +0100, Zdenek Kabelac wrote:
>> Ok - and now I'm getting confused and lost here.
>>
>> >From our chat I've got impression that using 'localedef' is perfectly valid
>> way how to create usable content for /usr/lib/locale.
> 
> True, but very costly one.
> 
> time for i in `cat /tmp/SUPPORTED`; do j=`echo $i | sed 's,/.*$,,'`; k=`echo $i | sed 's,^.*/,,'`; l=`echo $j | sed 's/\..*$//'`; localedef -A /usr/share/locale/locale.alias --no-archive -f $k -i $l -c /tmp/nyy/$j; done
> 
> real	6m12.985s
> user	5m34.818s
> sys	0m33.134s
> 
> Do you seriously suggest that we spend 6 minutes on very fast machines
> during glibc-common upgrades?  You must be joking.


Well update of my rawhide usually more then 3/4 hour - so 6 minutes running in
background - that's really nothing.

And quite frankly - during the update you need to update/recompile only
changed files - you could copy compiled & unchanged data to new file - thus in
fact it would takes couple seconds - unless each glibc update changes all i18n
locale definition, I doubt that - isn't that what the locale-archive.tmpl is
already doing?

(And as a bonus you save package size as you don't need to store tmpl inside)

Zdenek


