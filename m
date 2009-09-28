From: Alasdair G Kergon <agk@redhat.com>
Date: Mon, 28 Sep 2009 17:44:10 +0100
Subject: [PATCH 2/3] differentiate between S.I. and binary units in output
In-Reply-To: <1253979227-28051-2-git-send-email-impulze@impulze.org>
References: <1253979227-28051-1-git-send-email-impulze@impulze.org>
	<1253979227-28051-2-git-send-email-impulze@impulze.org>
Message-ID: <20090928164410.GH5351@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

So please would you:
  1) Make this change conditional on a runtime check of
cmd->si_unit_consistency;
  2) Remove the 500-byte sector offering.

The new-style output can be the default from 2.02.54 onwards - Fedora
13, RHEL6 etc.

People who find problems with their scripts after an upgrade can easily
reinstate the old inconsistent output by using an lvm.conf setting.

Distros that can't change the output (e.g. RHEL5) can set a configure
parameter.

Alasdair


