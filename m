From: Alasdair G Kergon <agk@redhat.com>
Date: Fri, 23 Apr 2010 00:38:57 +0100
Subject: [PATCH] Utilize new IMPORT{db} udev rule to repopulate udev db for spurious events
In-Reply-To: <4BCDBF80.3010902@redhat.com>
References: <4BCDBF80.3010902@redhat.com>
Message-ID: <20100422233856.GC23791@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Tue, Apr 20, 2010 at 04:51:44PM +0200, Peter Rajnoha wrote:
> @@ -44,6 +44,28 @@ ENV{DM_COOKIE}=="?*", IMPORT{program}="$env{DM_SBIN_PATH}/dmsetup udevflags $env
  
> +IMPORT{db}="DM_UDEV_DISABLE_DM_RULES_FLAG"

How does this cope if an older version of udev is installed?

Do we need to install/activate it conditionally?

Alasdair


