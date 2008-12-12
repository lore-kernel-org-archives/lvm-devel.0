From: James Cameron <james.cameron@hp.com>
Date: Fri, 12 Dec 2008 14:22:07 +1100
Subject: [PATCH] Create _init_globals() and call from bottom of create_toolcontext().
In-Reply-To: <1229051721-14977-1-git-send-email-dwysocha@redhat.com>
References: <20081211231005.GM24785@agk.fab.redhat.com>
	<1229051721-14977-1-git-send-email-dwysocha@redhat.com>
Message-ID: <20081212032207.GN3742@hp.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Move init_full_scan_done(0) and init_mirror_in_sync(0) from init_lvm()
after call to create_toolcontext() to _init_globals(), called from bottom
of create_toolcontext().  No functional change.

Acked-by: James Cameron <james.cameron@hp.com>

-- 
James Cameron
http://ftp.hp.com.au/sigs/jc/


