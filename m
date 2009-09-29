From: Alasdair G Kergon <agk@redhat.com>
Date: Tue, 29 Sep 2009 12:08:12 +0100
Subject: [PATCH 2/3] Fix possible lost of temporary devices in pvmove.
In-Reply-To: <4AC1A586.4080303@redhat.com>
References: <4AB254F7.5050509@redhat.com>
	<20090928194440.GL5351@agk-dp.fab.redhat.com>
	<4AC1A586.4080303@redhat.com>
Message-ID: <20090929110812.GN5351@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Tue, Sep 29, 2009 at 08:13:26AM +0200, Milan Broz wrote:
> And it leads to data corruption, see  https://bugzilla.redhat.com/show_bug.cgi?id=520913
 
Any data corruption is not a consequence of bogus udev rules.
It's a consequence of incorrect error handling in the lvm2 code.

Alasdair


