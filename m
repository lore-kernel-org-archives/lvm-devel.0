Received: from mail.gathman.org (mail.gathman.org [174.64.33.221])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A6DBA137932;
	Thu,  7 Aug 2025 15:31:41 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=174.64.33.221
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1754580706; cv=none; b=ol68xOB2g8ujUixYdoshEHIncBiJV5ApYrdjXRQSXPCU/F0vWu87X6JhCKRNkRN8+roPbXbtQqaiN8VGnpF9rYUkg37CgqrWDArwm2Yb0R0qsyKAn7hstCTf6RMCBeGTD1UtY4AuxgOLGNJPy+NeB1nWyDAbrhqFloyoXtU8wEI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1754580706; c=relaxed/simple;
	bh=Y1Ng45fpXpgQJBQqa9F6U0g/fEMzzrrwjUQTbhM/kv0=;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:
	 MIME-Version:Content-Type; b=AQVP9Po+IBtc0bIwNky+wz1zpBtjCL/5HtQ1ec8hjiiAuUJpcHmYnrC2MB3zwB6zgPHjjx0JnXWVapPMLkhimAO+GM0NOM63+Q2sClcQYCxEFl+0JWQwrOTZRAfdtWgHgPL/tiEAODmhEAuHklyTen+vVUYhBTrzXZF+7jPH+4U=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=gathman.org; spf=pass smtp.mailfrom=gathman.org; dkim=pass (1024-bit key) header.d=gathman.org header.i=@gathman.org header.b=Pj9gf3wE; arc=none smtp.client-ip=174.64.33.221
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=gathman.org
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gathman.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=gathman.org header.i=@gathman.org header.b="Pj9gf3wE"
Authentication-Results: mail.gathman.org; iprev=pass policy.iprev="2001:470:8:809::1010" (wiki.gathman.org); auth=pass (CRAM-MD5 sslbits=256) smtp.auth=stuart
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=gathman.org; 
 i=@gathman.org; q=dns/txt; s=default; t=1754580670; 
 h=date : from : to : cc : subject : in-reply-to : 
 message-id : references : mime-version : content-type : 
 date : from : subject; 
 bh=Y1Ng45fpXpgQJBQqa9F6U0g/fEMzzrrwjUQTbhM/kv0=; 
 b=Pj9gf3wEbF7VbNPXFYalPgC0iFEz6ZTzK1J5xT04zQukEg/9Vo7mLdxa
 qBSdpqRNsiBZYltOAF9FRgDFI2o/AgU0SB1dtOAR38Sprl1z7oVbZY9V+t
 uxYQFyhrRxzD875Cp7xwfU7iI9SNLH93P4byovxxftA/x1VeOlDAphagw=
Received: from wiki.gathman.org (wiki.gathman.org [IPv6:2001:470:8:809::1010])
	(authenticated bits=0)
	by mail.gathman.org (8.14.7/8.14.7) with ESMTP id 577FV7vs030887
	(version=TLSv1/SSLv3 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO);
	Thu, 7 Aug 2025 11:31:10 -0400
Date: Thu, 7 Aug 2025 11:31:07 -0400 (EDT)
From: Stuart D Gathman <stuart@gathman.org>
To: John Stoffel <john@stoffel.org>
cc: Mikulas Patocka <mpatocka@redhat.com>, Peter Rajnoha <prajnoha@redhat.com>,
        Zdenek Kabelac <zkabelac@redhat.com>,
        Heinz Mauelshagen <heinzm@redhat.com>,
        David Teigland <teigland@redhat.com>, linux-lvm@lists.linux.dev,
        lvm-devel@lists.linux.dev
Subject: Re: [PATCH] fix random failures in shell/integrity.sh
In-Reply-To: <26772.47717.267782.824503@quad.stoffel.home>
Message-ID: <6eb7fb27-524c-986e-c2af-e8bc8d7157f@gathman.org>
References: <06d25902-7239-1fc7-ec3b-1798332c3315@redhat.com> <26771.51188.491376.658337@quad.stoffel.home> <65919799-842c-9428-8bfc-5c1c0671338@gathman.org> <36d044e7-75f0-9b53-8969-0423fade7ea7@redhat.com> <26772.47717.267782.824503@quad.stoffel.home>
Precedence: bulk
X-Mailing-List: lvm-devel@lists.linux.dev
List-Id: <lvm-devel.lists.linux.dev>
List-Subscribe: <mailto:lvm-devel+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:lvm-devel+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII; format=flowed

On Thu, 7 Aug 2025, John Stoffel wrote:

>
> And how do you know which level of the array is showing the errors?  I
> could have a RAID1 array composed of a single partition on the left
> side, but then a RAID0 of two smaller disks on the right side.  So how
> would this read() flag know what to do?

Modern filesystems like btrfs (and xfs for metadata) have csums on
extents.  So they know which version is good.  Btrfs can do it's own
version of raid1, with multiple copies of each extents on different 
devices.  But this doesn't integrate well with LVM. (It's great for
arrays of external USB disks for archival purposes.)  LVM is 
more efficient as a base - especially for use with KVM virtual machines.
(You could use containers on btrfs, but I like the better security
of KVM despite higher CPU usage.)

> I would assume the integrity sub-system would be reading from both
> sides and comparing them to look for errors.  When you find a
> mis-match, how do you tell which side is wrong?

Modern filesystems have csums on extents.  There is an integrity layer
for dm that also does this.  Both filesystems and integrity layer
need a way to read all versions of a block/extent to see which is
correct.

