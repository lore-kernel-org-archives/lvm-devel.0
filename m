From: Milan Broz <mbroz@redhat.com>
Date: Sun, 10 May 2009 20:42:53 +0200
Subject: [PATCH 2/7] Never set mirror log and images directly visible in metadata.
In-Reply-To: <87my9ku7t9.fsf@eriador.mornfall.net>
References: <cover.1241620083.git.mbroz@redhat.com>	<cover.1241620083.git.mbroz@redhat.com>	<a3d0392fa15ad5ecbc874cb5419a0177011655ed.1241620083.git.mbroz@redhat.com>
	<87my9ku7t9.fsf@eriador.mornfall.net>
Message-ID: <4A07202D.1010903@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Petr Rockai wrote:
> Milan Broz <mbroz@redhat.com> writes:
>> Mirror creation and conversion force set mirror log and images
>> to be visible. This can violate VG max_lv restriction on LV.
>>
>> There is no need to set these volumes visible, even during
>> mirror images conversion.
> Well, I believe the use-case is that when the operation fails halfway (which
> happens from time to time -- more often than would be comfortable, even), you
> can clean up by hand, since those offending LVs became visible. If there is a
> reasonable procedure that the admins can follow to get rid of the junk LVs in
> those scenarios, I'm fine.

Maybe we should display these "invisible" LVs to user (in reporting commands)
if no visible LV references them (I mean _mimage, _mlog & Co. devices)

Admin can remove these insvible LV even now (lvremove works), but must
run "lvs -a" to found them first...

Milan


