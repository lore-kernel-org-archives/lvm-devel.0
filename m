From: Milan Broz <mbroz@redhat.com>
Date: Sun, 27 Feb 2011 11:49:15 +0100
Subject: LVM2 ./WHATS_NEW doc/example.conf.in lib/confi ...
In-Reply-To: <20110227003833.23186.qmail@sourceware.org>
References: <20110227003833.23186.qmail@sourceware.org>
Message-ID: <4D6A2C2B.10209@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 02/27/2011 01:38 AM, agk at sourceware.org wrote:
> Log message:
> 	Various changes to the allocation algorithms: Expect some fallout.
> 	There is a lot to test.
> 	
> 	Two new config settings added that are intended to make the code behave
> 	closely to the way it did before - worth a try if you find problems.

if the new node is correct, can you please fix also tests to not fail?

no change in man page (--alloc description) needed here?

Milan


