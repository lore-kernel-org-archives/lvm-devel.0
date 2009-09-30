From: Alasdair G Kergon <agk@redhat.com>
Date: Wed, 30 Sep 2009 15:20:57 +0100
Subject: [PATCH 2/3] differentiate between S.I. and binary units in output
In-Reply-To: <4AC2AD92.4040603@impulze.org>
References: <1253979227-28051-1-git-send-email-impulze@impulze.org>
	<1253979227-28051-2-git-send-email-impulze@impulze.org>
	<20090928164410.GH5351@agk-dp.fab.redhat.com>
	<4AC2AD92.4040603@impulze.org>
Message-ID: <20090930142056.GU5351@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

OK - I've applied this.

I added a 'base' value within the array and some #defines to try to make
the code easier to understand.  Hopefully I didn't introduce any bugs
during that process.

Alasdair


