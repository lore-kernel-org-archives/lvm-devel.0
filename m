From: Dave Wysochanski <dwysocha@redhat.com>
Date: Mon, 17 Aug 2009 09:32:50 -0400
Subject: [PATCH 14]: Prototype vgsplit and vgmerge for alphabetical VG lock
In-Reply-To: <1250198823-11591-1-git-send-email-dwysocha@redhat.com>
References: <1250198823-11591-1-git-send-email-dwysocha@redhat.com>
Message-ID: <1250515971-8240-1-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


This patch just shows how liblvm would be restricted and vgsplit/vgmerge
defined for the new alphabetical lock ordering.  Note that this is one option
for implementing the restriction - the other one is to allow multiple VGs open
but require the application to open in the correct order.  I suppose a 3rd
option would be implicitly releasing / reacquiring VG locks, but then we'd
have to handle the fallout from locking failure and/or blocking.


