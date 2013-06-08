From: Bastian Blank <waldi@debian.org>
Date: Sat, 8 Jun 2013 11:51:24 +0200
Subject: [PATCH 0/3] Use udev monitor
Message-ID: <20130608094939.GA3065@mail.waldi.eu.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This patch set rips out the custom synchronisation option via sysv
semaphores and replaces it with udev monitor via netlink.

Bastian Blank (3):
  udev: Rip out semaphore synchronisation support
  udev: Save open udev state
  udev: Use udev monitor

 libdm/libdm-common.c |  368 +++++++++++++++-----------------------------------
 1 file changed, 107 insertions(+), 261 deletions(-)

-- 
Totally illogical, there was no chance.
		-- Spock, "The Galileo Seven", stardate 2822.3


