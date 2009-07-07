From: Dave Wysochanski <dwysocha@redhat.com>
Date: Tue,  7 Jul 2009 00:24:20 -0400
Subject: [PATCH 0/4]: Remove unnecessary flags from new vg_read() APIs and tools
Message-ID: <1246940664-14890-1-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


The following 4 patches remove various flags from the new vg_read() interface.
Many of these flags provided a useful stepping stone from where we were,
but now it would be good to simplify the API as much as possible.


