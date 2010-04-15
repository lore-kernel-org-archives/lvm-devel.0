From: Alasdair G Kergon <agk@redhat.com>
Date: Thu, 15 Apr 2010 23:15:16 +0100
Subject: [PATCH] Add creation of dev/mapper/control to nightly tests.
In-Reply-To: <1271363998-4897-1-git-send-email-dwysocha@redhat.com>
References: <1271363998-4897-1-git-send-email-dwysocha@redhat.com>
Message-ID: <20100415221516.GP13021@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Thu, Apr 15, 2010 at 04:39:58PM -0400, Dave Wysochanski wrote:
> /tmp/LVMTEST26998.J29FayOVWy/dev/mapper/control: matchpathcon 0020000 failed:

So after creating the subdir in /tmp, set its selinux label to something more
appropriate.

Alasdair


