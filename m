From: Jonathan Brassow <jbrassow@redhat.com>
Date: Wed, 23 Jun 2010 15:56:02 -0500
Subject: LVM2/tools lvconvert.c
In-Reply-To: <20100623204919.GC14902@agk-dp.fab.redhat.com>
References: <20100623203231.28578.qmail@sourceware.org>
	<20100623204919.GC14902@agk-dp.fab.redhat.com>
Message-ID: <235872D4-9DD5-47E2-A73C-54D617ECCD72@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Yep, I should have just entered the whole thing instead of summarizing  
so tersely...  Here is the original dialog in the patch that was sent.

  brassow

<taka>
I found a case that lvconvert command can't repair failed lvm
mirror volume. When a mirror leg and a mirror log failed at the
same time, lvconvert --repair can't handle the error.

Before mirrored log function was introduced, the sequence of
repair was

  1. Fix mirror legs ... lv_remove_mirrors()
  2. Fix mirror log  ... _lv_update_log_type()

and after mirrored log function was introduced, the sequence was
changed as follows because a recovery of mirror log should be done
before a recovery of mirror leg is done.

  1. Fix mirror log  ... _lv_update_log_type()
  2. Fix mirror legs ... lv_remove_mirrors()

It seems to introduced this issue. In _lv_update_log_type() function
handles not only mirror log but also mirror leg and it does not seem
to work properly.

One of the solutions to fix this issue is to change the sequence as
the one before mirror log function was introduced and to add
a function to handle a failure of mirrored log before mirror leg is
recovered.

  1. Fix mirrored log ... _lv_update_log() <NEW function>
     _lv_update_log() handles errors inside mirrored log and doesn't
     change an original lv.
  2. Fix mirror legs  ... lv_remove_mirrors()
  3. Fix mirror log   ... _lv_update_log_type()

I created a RFC patch and it worked well for my test cases.
</taka>

On Jun 23, 2010, at 3:49 PM, Alasdair G Kergon wrote:

> On Wed, Jun 23, 2010 at 08:32:31PM -0000, jbrassow at sourceware.org  
> wrote:
>> 	the failure of a device that contained both a image of
>> 	a mirror and an image of the mirrored log.  The order
>> 	of the handling of those faults was important (and
>> 	wrong), this patch corrects that.
>
> "order...was important...and wrong...this patch corrects..."
>
> Can you be a bit more specific?
> Why was it important?
> What was wrong about it?
> What does this patch do to correct it?
>
> We need something more precise for WHATS_NEW.
> 	
> Alasdair
>
> --
> lvm-devel mailing list
> lvm-devel at redhat.com
> https://www.redhat.com/mailman/listinfo/lvm-devel


