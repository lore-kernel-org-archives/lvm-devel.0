From: Peter Rajnoha <prajnoha@redhat.com>
Date: Fri, 27 Sep 2013 11:59:06 +0200
Subject: [PATCH] pvcreate: Create a bootloader embedding area by default
In-Reply-To: <1380180824-17931-1-git-send-email-g2p.code@gmail.com>
References: <1380180824-17931-1-git-send-email-g2p.code@gmail.com>
Message-ID: <524556EA.9000601@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 09/26/2013 09:33 AM, Gabriel de Perthuis wrote:
> Default to 1M, to match the amount available to the bootloader on a
> partition table with modern alignment constraints.

Well, I'd really prefer having this on-demand only by explicit use of
"pvcreate --bootloaderareasize". The bootloader area is supposed to
be used in specific situations only and we normally don't want it to
be created for all PVs by default...

Peter


