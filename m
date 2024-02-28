Received: from verein.lst.de (verein.lst.de [213.95.11.211])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E774C5E070;
	Wed, 28 Feb 2024 19:56:41 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=213.95.11.211
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1709150204; cv=none; b=AZVegzw/e4JD6/9238fb+xQMzO0vDR1BepTyLxK216B6ZuT473m8coLyA8P5LNvrJHjmb9/vHYhTTIEV2uV2G7WkNXBh3EE6VtjDFNQyYuomb2Ij8s7egtb5bKrctpN7aVEw8AHXInNpOvqBUVynMcMOzkghSlG4I+Csk7d9cLI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1709150204; c=relaxed/simple;
	bh=HDh1ILBZ0Iw5s11JkdJ26MeMnFxuyM5gEXdWewJTJTU=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=OdZ5zIiNFuQqez23/JAZiDo5exKdvtgqIbCidFZRZiejNR7DXk38BmJ1hFgXZMa4Z1bzCyQisS+t4vgbfm1d1HnS6QMI/BQUTti6WLhBrV+oN1IJF1ZSSEi5h+eyi7UKDVBxJuyx3qljSGfg3bXS7qI+O9S7vY4KeflBgE8bZQo=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de; spf=pass smtp.mailfrom=lst.de; arc=none smtp.client-ip=213.95.11.211
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id 694AB68D05; Wed, 28 Feb 2024 20:56:32 +0100 (CET)
Date: Wed, 28 Feb 2024 20:56:32 +0100
From: Christoph Hellwig <hch@lst.de>
To: Song Liu <song@kernel.org>
Cc: Mike Snitzer <snitzer@kernel.org>,
	Benjamin Marzinski <bmarzins@redhat.com>, Xiao Ni <xni@redhat.com>,
	Zdenek Kabelac <zkabelac@redhat.com>,
	Christoph Hellwig <hch@lst.de>, Jens Axboe <axboe@kernel.dk>,
	Mikulas Patocka <mpatocka@redhat.com>, Yu Kuai <yukuai3@huawei.com>,
	dm-devel@lists.linux.dev, linux-block@vger.kernel.org,
	linux-raid@vger.kernel.org, lvm-devel@lists.linux.dev
Subject: Re: atomic queue limit updates for stackable devices
Message-ID: <20240228195632.GA20077@lst.de>
References: <20240223161247.3998821-1-hch@lst.de> <ZdjXsm9jwQlKpM87@redhat.com> <ZdjYJrKCLBF8Gw8D@redhat.com> <20240227151016.GC14335@lst.de> <Zd38193LQCpF3-D0@redhat.com> <20240227151734.GA14628@lst.de> <Zd4BhQ66dC_d7Mn0@redhat.com> <CAPhsuW69mM3tEBR=SgKy_SYE+NUsNO+8H6toyk+5mKcSfGMjmg@mail.gmail.com>
Precedence: bulk
X-Mailing-List: lvm-devel@lists.linux.dev
List-Id: <lvm-devel.lists.linux.dev>
List-Subscribe: <mailto:lvm-devel+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:lvm-devel+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPhsuW69mM3tEBR=SgKy_SYE+NUsNO+8H6toyk+5mKcSfGMjmg@mail.gmail.com>
User-Agent: Mutt/1.5.17 (2007-11-01)

On Tue, Feb 27, 2024 at 01:50:19PM -0800, Song Liu wrote:
> I think we can do something like:
> 
> make check S=<list of test to skip>
> 
> I don't have a reliable list to skip at the moment, as some of the tests
> fail on some systems but not on others. However, per early report,
> I guess we can start with the following skip list:
> 
> shell/integrity-caching.sh
> shell/lvconvert-raid-reshape-linear_to_raid6-single-type.sh
> shell/lvconvert-raid-reshape.sh

Thanks.  I've been iterating over it this morning, eventually growing
to:

make check
S=shell/integrity-caching.sh,shell/lvconvert-raid-reshape-linear_to_raid6-single-type.sh,shell/lvconvert-raid-reshape.sh,shell/lvconvert-raid-reshape-linear_to_striped-single-type.sh,shell/lvconvert-raid-reshape-linear_to_striped.sh,shell/lvchange-raid456.sh,shell/component-raid.sh,shell/lvconvert-raid-reshape-load.sh,shell/lvchange-raid-transient-failures.sh,shell/lvconvert-raid-reshape-striped_to_linear-single-type.sh,shell/lvconvert-raid-reshape-striped_to_linear.sh,shell/lvconvert-raid-reshape-stripes-load-fail.sh,shell/lvconvert-raid-reshape-stripes-load-reload.sh,shell/lvconvert-raid-reshape-stripes-load.sh,lvconvert-raid-reshape.sh,shell/lvconvert-raid-restripe-linear.sh,shell/lvconvert-raid-status-validation.sh,shell/lvconvert-raid-takeover-linear_to_raid4.sh,shell/lvconvert-raid-takeover-raid4_to_linear.sh,shell/lvconvert-raid-takeover-alloc-failure.sh

before giving up.  I then tried to run the md-6.9 branch that's
supposed to have the fixes, but I still see the same md_stop_writes
hangs.
