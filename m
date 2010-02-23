From: Jakub Jelinek <jakub@redhat.com>
Date: Tue, 23 Feb 2010 10:45:11 +0100
Subject: lvm and locales memory issue
In-Reply-To: <4B839C8F.5030103@redhat.com>
References: <4B7D4014.3010205@redhat.com> <4B7EB81D.6090405@redhat.com>
	<20100219163008.GR27427@agk-dp.fab.redhat.com>
	<4B8262A2.4050408@redhat.com> <4B8283B6.7000808@redhat.com>
	<20100222181150.GA32020@agk-dp.fab.redhat.com>
	<20100222182301.GR2817@tyan-ft48-01.lab.bos.redhat.com>
	<4B839743.8020909@redhat.com>
	<20100223091539.GV2817@tyan-ft48-01.lab.bos.redhat.com>
	<4B839C8F.5030103@redhat.com>
Message-ID: <20100223094511.GW2817@tyan-ft48-01.lab.bos.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Tue, Feb 23, 2010 at 10:14:55AM +0100, Zdenek Kabelac wrote:
> Well update of my rawhide usually more then 3/4 hour - so 6 minutes running in
> background - that's really nothing.

Perhaps you don't care, but others do really care.

> And quite frankly - during the update you need to update/recompile only
> changed files - you could copy compiled & unchanged data to new file - thus in
> fact it would takes couple seconds - unless each glibc update changes all i18n
> locale definition, I doubt that - isn't that what the locale-archive.tmpl is
> already doing?

There is a big tree of inclusions between the locale files, so you'd need to
checksum them together with all the dependencies.  Anyway, that would still
leave us with 6 minutes (on slow machines maybe half an hour) during Fedora
installation.  I don't understand your sudden holy war against generated
data in the distro, after all the locales aren't definitely the largest (but
is something everybody has installed).  Look at stuff like kdelibs-apidocs
or asterisk-apidoc which are 650+ resp. 320+ MB of generated data.
And this wouldn't help you in any way for lvm, locale-archive would be the
same size...

	Jakub


