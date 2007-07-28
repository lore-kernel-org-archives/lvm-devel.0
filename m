From: Jim Meyering <jim@meyering.net>
Date: Sat, 28 Jul 2007 15:06:46 +0200
Subject: new device-mapper required to build latest lvm from cvs
In-Reply-To: <46A7AB23.7050306@ce.jp.nec.com> (Jun'ichi Nomura's message of
	"Wed\, 25 Jul 2007 15\:57\:23 -0400")
References: <87wswplmgl.fsf@rho.meyering.net> <46A7AB23.7050306@ce.jp.nec.com>
Message-ID: <87sl78wuc9.fsf@rho.meyering.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

"Jun'ichi Nomura" <j-nomura@ce.jp.nec.com> wrote:
> Jim Meyering wrote:
>> FYI, with the change I've just committed,
>>
>>   http://sources.redhat.com/ml/lvm2-cvs/2007-07/msg00035.html
>>
>> you now need a device-mapper library and headers built from
>> today's cvs sources.  Otherwise, you'll get compile warnings
>> and eventually a link error complaining about missing dm_fclose.
>
> This change introduces an error for static build.

Thank you for the report and the patches.
I've applied four of your patches, three for device-mapper
and one for lvm2:

dm
  Export dm_create_dir (was create_dir) to help fix LVM2 link error
    http://git.et.redhat.com/?p=device-mapper.git;a=commitdiff;h=8748390a79f
  Don't log mkdir fail-with-EROFS, to make create_dir equiv to that in LVM2
    http://git.et.redhat.com/?p=device-mapper.git;a=commitdiff;h=81d93dd4717
  Introduce and use log_sys_* macros from LVM2
    http://git.et.redhat.com/?p=device-mapper.git;a=commitdiff;h=5edca96def8

lvm2
  Remove create_dir function; use now-equivalent dm_create_dir instead
    http://git.et.redhat.com/?p=lvm2.git;a=commitdiff;h=7d85f48b35b7


