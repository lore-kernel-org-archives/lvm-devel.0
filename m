From: Malahal Naineni <malahal@us.ibm.com>
Date: Sun, 13 Dec 2009 01:18:42 -0800
Subject: [PATCH 0 of 4] Re-integrate a failed secondary mirror leg
Message-ID: <patchbomb.1260695922@localhost>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

The following 4 patches try to re-integrate a failed secondary mirror leg.

Patch 1: Re-arranges some code and introduces more error type returns
Patch 2: Tries to re-integrate the failed device indefinitely
Patch 3: Removes some "#ifdef 0' code and fixes timeout setup mechanism.
         Also adds interface to remove a timeout setup
Patch 4: Uses Patch 2 and Patch 3 to attempt only few times at a regular
         interval to resync the failed mirror.

Tested with flakey dm module!


