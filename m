From: Dave Wysochanski <dwysocha@redhat.com>
Date: Mon,  6 Jul 2009 08:50:29 -0400
Subject: [PATCH v2] Fix vg_read() error paths to properly release upon vg_read_error()
In-Reply-To: <1246630100-26016-1-git-send-email-dwysocha@redhat.com>
References: <1246630100-26016-1-git-send-email-dwysocha@redhat.com>
Message-ID: <1246884630-4898-1-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


This patch supercedes previous patch and should be ready for review/commit.
The first iteration of this patch contained a few unnecessary vg_release()
calls - tools that use iterators do not need to release since the iterators
do the release.


