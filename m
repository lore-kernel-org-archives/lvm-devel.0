From: Petr Rockai <prockai@redhat.com>
Date: Fri, 12 Dec 2008 10:22:12 +0100
Subject: [PATCH] (1/2) new library interface for vg_read
In-Reply-To: <1229028451.20795.22.camel@localhost.localdomain> (Dave
	Wysochanski's message of "Thu, 11 Dec 2008 15:47:31 -0500")
References: <87y6ypcn7l.fsf@eriador.mornfall.net>
	<1229028451.20795.22.camel@localhost.localdomain>
Message-ID: <87iqppbvej.fsf@eriador.mornfall.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

Dave Wysochanski <dwysocha@redhat.com> writes:
> Can you clean up some of the return value prototypes so they use
> uint32_t consistently for return values?  This includes
> vg_check_status(), vg_read_error(), vg_exists(), and the flag
> definitions.
I have changed those, plus removed the warning you mentioned in other mail,
I'll probably re-add separately later. I'm attaching new-changes and new-all,
first just giving the diff against the previous version of the patch. I'm not
sure I agree that they should all be uint32_t though, but I suppose it's a
minor point.

The diff-diff:

-------------- next part --------------
A non-text attachment was scrubbed...
Name: new-changes.diff
Type: text/x-diff
Size: 2828 bytes
Desc: new-changes.diff
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20081212/a20c350c/attachment.bin>
-------------- next part --------------

And the full-diff:

-------------- next part --------------
A non-text attachment was scrubbed...
Name: new-all.diff
Type: text/x-diff
Size: 16639 bytes
Desc: new-all.diff
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20081212/a20c350c/attachment-0001.bin>
-------------- next part --------------

Yours,
   Petr.

-- 
Peter Rockai | me()mornfall!net | prockai()redhat!com
 http://blog.mornfall.net | http://web.mornfall.net

"In My Egotistical Opinion, most people's C programs should be
 indented six feet downward and covered with dirt."
     -- Blair P. Houghton on the subject of C program indentation
