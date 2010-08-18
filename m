From: Dave Wysochanski <dwysocha@redhat.com>
Date: Wed, 18 Aug 2010 09:51:51 -0400
Subject: [PATCH 00/11] Add lvm vg properties for lvm2app.
Message-ID: <1282139522-31240-1-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This patchset is a rebase and redo of earlier patchsets posted to
implement generic functions to query any value of a field in an
lvm report.  The patchset extends the reporting infrastructure
and then adds a generic lvm2app structure and function to return
any vg-based report field.


