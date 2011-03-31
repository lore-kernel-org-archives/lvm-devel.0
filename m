From: Alasdair G Kergon <agk@redhat.com>
Date: Thu, 31 Mar 2011 07:33:40 +0100
Subject: Filtering out LVs?
In-Reply-To: <4D91BDA7.2030003@ce.jp.nec.com>
References: <4D91BDA7.2030003@ce.jp.nec.com>
Message-ID: <20110331063340.GB4849@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Tue, Mar 29, 2011 at 08:08:23PM +0900, Jun'ichi Nomura wrote:
> So there is a race that one of multiple vgchange instances prevents other;
> "vgchange -an vg0" might fail to deactivate the VG if "vgchange -an vg1"
> opens vg0/lv0 at the very time for scanning.
 
I'm inclined not to do anything about this at the moment, but to wait until
udev+new cache work is complete then revisit it if the problem hasn't
gone away.

Alasdair


