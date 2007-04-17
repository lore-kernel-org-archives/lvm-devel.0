From: Dave Wysochanski <dwysocha@redhat.com>
Date: Tue, 17 Apr 2007 13:23:42 -0400
Subject: [PATCH 0/2] Add support functions for reading old LVM2 metadata
Message-ID: <1176830622.4070.18.camel@linux-cxyg>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Two patches follow that should not change LVM2 functional behavior.
They add some additional functions and minor cleanups to facilitate
later patches that will read old LVM2 metadata, providing some of the
guts for 'pvck'.




