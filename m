From: Alasdair G Kergon <agk@redhat.com>
Date: Sat, 16 Mar 2013 19:12:32 +0000
Subject: [PATCH] libdevmapper.h: make this include file standard-compliant
In-Reply-To: <Pine.LNX.4.64.1303161221480.4777@file.rdu.redhat.com>
References: <Pine.LNX.4.64.1303161221480.4777@file.rdu.redhat.com>
Message-ID: <20130316191232.GF27858@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Is there any reason for any of the code to try to support c89 these days?

I was assuming c99 as the miniumum and saw no need to support c89.

Alasdair


