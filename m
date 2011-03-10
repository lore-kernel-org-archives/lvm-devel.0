From: Dave Wysochanski <dwysocha@redhat.com>
Date: Thu, 10 Mar 2011 15:11:28 -0500
Subject: Any plans to improve kernel memory usage of a single snapshot?
Message-ID: <1299787888.5157.6.camel@f12-work>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Just wondering if there are any plans to improve memory usage beyond the
existing implementation (24-32 bytes per exception in dm-snapshot-ex).

IMO existing implementation is quite good but a customer is asking
whether there are plans to improve the memory footprint of a single
snapshot.

Thanks.


