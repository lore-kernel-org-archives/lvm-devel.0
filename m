From: Petr Rockai <prockai@redhat.com>
Date: Thu, 22 Jan 2009 21:15:40 +0100
Subject: [PATCH 3/14] Properly enforce cluster locking in _vg_lock_and_read.
In-Reply-To: <1232648223.8897.9.camel@localhost.localdomain> (Dave
	Wysochanski's message of "Thu, 22 Jan 2009 13:17:03 -0500")
References: <1232619010-4858-1-git-send-email-prockai@redhat.com>
	<1232619010-4858-2-git-send-email-prockai@redhat.com>
	<1232619010-4858-3-git-send-email-prockai@redhat.com>
	<1232619010-4858-4-git-send-email-prockai@redhat.com>
	<1232648223.8897.9.camel@localhost.localdomain>
Message-ID: <87ljt385cj.fsf@eriador.mornfall.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

Dave Wysochanski <dwysocha@redhat.com> writes:
> With this patch, is there any point in leaving that CLUSTERED flag check
> in _vg_check_status()?  The clustered flag set in vg_read() is not
> needed either (check is mandatory now - flag doesn't mean anything).
actually, it seems you are right. I left it in because there are calls to
vg_check_status scattered through the code -- I didn't realize that it is now
redundant. However, there are still users of that check that are removed by
subsequent patches in the series. So to keep things working without requiring
all of the series to be applied, it should stay there. I'll remove it in an
extra patch on top of the stack.

Yours,
   Petr.

-- 
Peter Rockai | me()mornfall!net | prockai()redhat!com
 http://blog.mornfall.net | http://web.mornfall.net

"In My Egotistical Opinion, most people's C programs should be
 indented six feet downward and covered with dirt."
     -- Blair P. Houghton on the subject of C program indentation


