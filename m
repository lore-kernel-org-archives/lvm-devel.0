From: Peter Rajnoha <prajnoha@redhat.com>
Date: Thu, 09 Apr 2009 12:37:47 +0200
Subject: [PATCH] Udev integration: udev rules 1/3
In-Reply-To: <49DC99BA.8000205@redhat.com>
References: <49DC99BA.8000205@redhat.com>
Message-ID: <49DDCFFB.3050200@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 04/08/2009 02:34 PM, Peter Rajnoha wrote:
> ACTION=="change", TEST!="dm", IMPORT{PROGRAM}="/sbin/dmsetup info -j %M -m %m -c --nameprefixes --noheadings --rows -o name"

...ehm, sorry, this should be:

ACTION=="change", TEST!="dm", IMPORT{PROGRAM}="/sbin/dmsetup info -j %M -m %m -c --nameprefixes --noheadings --rows -o name,uuid"

Missed the "uuid" field at the end -- otherwise the notification would
come prematurely in DM udev rule and not in LVM. We have to check this
uuid for prefix, and when there's an "LVM-" prefix, the notification
is done by the other rule -- the LVM one. This way it's correct.

Peter


