From: Peter Rajnoha <prajnoha@redhat.com>
Date: Mon, 19 Oct 2009 14:18:01 +0200
Subject: [PATCH 1/4] Introduce flags to control udev rules
In-Reply-To: <4ADC5192.7050607@redhat.com>
References: <4ADC5192.7050607@redhat.com>
Message-ID: <4ADC58F9.6050200@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

..just one important note - it's obvious, but it's worth pointing out.

These flags work only with kernels >= 2.6.31 (because it uses the
cookie value to pass the flags).

Peter


