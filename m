From: Joe Thornber <thornber@redhat.com>
Date: Tue, 29 Mar 2011 14:07:10 +0100
Subject: LVM2 lib/format_text/flags.c lib/metadata/lv.c ...
In-Reply-To: <20110329125200.16039.qmail@sourceware.org>
References: <20110329125200.16039.qmail@sourceware.org>
Message-ID: <1301404030.2949.2.camel@ubuntu>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Tue, 2011-03-29 at 12:52 +0000, jbrassow at sourceware.org wrote:
> CVSROOT:	/cvs/lvm2
> Module name:	LVM2
> Changes by:	jbrassow at sourceware.org	2011-03-29 12:51:58
> 
> Modified files:
> 	lib/format_text: flags.c 
> 	lib/metadata   : lv.c lv_manip.c metadata-exported.h mirror.c 
> 	tools          : lvchange.c lvconvert.c 
> 
> Log message:
> 	s/MIRROR_NOTSYNCED/LV_NOTSYNCED/ - Flag will may refer to more than just mirrors


ACK

Should this line be taken out too?

./lib/metadata/metadata.h:73://#define MIRROR_NOTSYNCED
0x00080000U     /* LV */




