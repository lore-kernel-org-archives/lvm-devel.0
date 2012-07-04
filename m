From: ben <benscott@nwlink.com>
Date: Wed, 4 Jul 2012 13:20:24 -0700
Subject: liblvm2app stripe_size reported wrong
Message-ID: <201207041320.24826.benscott@nwlink.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Using Debian liblvm2app2.2:amd64   version 2.02.95-4 the size of stripes on 
segments is reported incorrectly from the library function. The number of 
bytes is divided by 512, which I assume is sectors.

Thank you.




