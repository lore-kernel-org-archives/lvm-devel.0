From: Petr Rockai <prockai@redhat.com>
Date: Thu, 14 May 2009 08:59:09 +0200
Subject: [PATCH 2/9] Rework the toollib interface (process_each_*) on top of new vg_read.
In-Reply-To: <1242164797.2539.5.camel@f10-node1> (Dave Wysochanski's message
	of "Tue, 12 May 2009 17:46:37 -0400")
References: <1241350741-31349-1-git-send-email-prockai@redhat.com>
	<1241350741-31349-2-git-send-email-prockai@redhat.com>
	<1241350741-31349-3-git-send-email-prockai@redhat.com>
	<1242164797.2539.5.camel@f10-node1>
Message-ID: <87octw5fwi.fsf@mornfall.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dave Wysochanski <dwysocha@redhat.com> writes:

> Did you miss process_each_pv?  It looks to me like you missed a
> hunk/patch somewhere since process_each_pv still calls the old
> vg_read_internal().

In fact, I have mis-ordered the patches -- I have only sent a prefix to speed
up the process of getting at least those in. Please ignore the "Un-export
vg_read_internal" patch for now, it was supposed to go later in sequence. There
are still a few patches depending on those that need to be rebased, but it
doesn't really make sense to do until at least the groundwork is
in. (Especially since it may, sadly, take yet another rebase before these get
in, as it looks now...)

Yours,
   Petr.

-- 
Peter Rockai | me()mornfall!net | prockai()redhat!com
 http://blog.mornfall.net | http://web.mornfall.net

"In My Egotistical Opinion, most people's C programs should be
 indented six feet downward and covered with dirt."
     -- Blair P. Houghton on the subject of C program indentation


