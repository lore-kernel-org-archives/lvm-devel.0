From: Alasdair G Kergon <agk@redhat.com>
Date: Wed, 1 Feb 2017 11:14:28 +0000
Subject: lvm git "pre-release" "post-release" question
In-Reply-To: <94f92d6c-18cc-7c0b-3b21-8133fc587c9a@mglug.de>
References: <94f92d6c-18cc-7c0b-3b21-8133fc587c9a@mglug.de>
Message-ID: <20170201111428.GA24726@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Wed, Feb 01, 2017 at 11:38:14AM +0100, Oliver Rath wrote:
> every time you offer a new version number, in git I see these
> "pre-release" "post-release" commits. What is it good for? Is this a
> git-functionality or what kind of tool you are using for this?
 
Those commits simply update the version number/date and tidy the changelog
before/after generating a tarball.

Alasdair


