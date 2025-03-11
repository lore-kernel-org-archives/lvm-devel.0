Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 953F425E836
	for <lvm-devel@lists.linux.dev>; Tue, 11 Mar 2025 15:30:42 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.129.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1741707044; cv=none; b=G9+6odj1P3o/8Bw6YvJnXEhzZv0dbnPrKloX4Y+lPPrCaGYczdpYPlIz/6o6DT5AKGludYwc/KeTHsACkfKEMEtSpZz8vpF15r8LsJt2WufYRLGfMwCgyTXWdsqHNwIT3KzFnd7Yf1PWM2VJz9FEXyq+Td3icI/95DXusfMJQLg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1741707044; c=relaxed/simple;
	bh=EUkaoZhwCKRRtD4jnL5ZIxKZ2/zLcF2o0/v67nqMHrw=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 In-Reply-To:Content-Type:Content-Disposition; b=fTdnDeUCaNr21XMOnl64MheuE5mymYoWGHzM5UBzECQc0i2rQ1hGmW4hQsF5M9YgkScO7W07e/SB3fMCj0Ic5cOAyk4H3FpiC/T4m+kuVnsryzr+4cQlfxwR5pBA7OqQJW1imN3aGbOQZ3S1fllxKXvkiEjY8zM+KEjfP5FOwoc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=OV2N368u; arc=none smtp.client-ip=170.10.129.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="OV2N368u"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1741707041;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=EUkaoZhwCKRRtD4jnL5ZIxKZ2/zLcF2o0/v67nqMHrw=;
	b=OV2N368uKARwfqc4N/8X/v57B2FwZzmonQEOcJkDaUj5qIGxMWTGxSXS7JEsbC8AyhEZHC
	ec4d4q2Tmqhzhz85DJgqHvwxw5mENii9Jg1K57KUkr6qre5/VOqrpzzBEwPqkFQrTMOlea
	qwtNZy8BN7FrMH5ymRVU/n2N1wAduQI=
Received: from mx-prod-mc-02.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-54-186-198-63.us-west-2.compute.amazonaws.com [54.186.198.63]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-315-4yFQuxPUMoKLk_CDWhnUJA-1; Tue,
 11 Mar 2025 11:30:38 -0400
X-MC-Unique: 4yFQuxPUMoKLk_CDWhnUJA-1
X-Mimecast-MFC-AGG-ID: 4yFQuxPUMoKLk_CDWhnUJA_1741707036
Received: from mx-prod-int-01.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-01.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.4])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-02.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id D3BA319560BB;
	Tue, 11 Mar 2025 15:30:35 +0000 (UTC)
Received: from redhat.com (unknown [10.22.66.35])
	by mx-prod-int-01.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id A42F53001D0E;
	Tue, 11 Mar 2025 15:30:34 +0000 (UTC)
Date: Tue, 11 Mar 2025 10:30:32 -0500
From: David Teigland <teigland@redhat.com>
To: Glass Su <glass.su@suse.com>
Cc: lvm-devel@lists.linux.dev, zkabelac@redhat.com,
	Heming Zhao <heming.zhao@suse.com>
Subject: Re: Request for comments about support btrfs in lvresize
Message-ID: <Z9BXGHbpDqLUW7Hr@redhat.com>
References: <D418C150-C1F3-4067-9B72-65C4542DF19F@suse.com>
 <Z88QTwcyqqn-faz_@redhat.com>
 <C6FA4A06-7C7B-415E-A46E-302E1CAE9E36@suse.com>
Precedence: bulk
X-Mailing-List: lvm-devel@lists.linux.dev
List-Id: <lvm-devel.lists.linux.dev>
List-Subscribe: <mailto:lvm-devel+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:lvm-devel+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
In-Reply-To: <C6FA4A06-7C7B-415E-A46E-302E1CAE9E36@suse.com>
X-Scanned-By: MIMEDefang 3.4.1 on 10.30.177.4
X-Mimecast-Spam-Score: 0
X-Mimecast-MFC-PROC-ID: hJiEFk1_EhqrWixwQBt2VXfmvuuHKqz75NQNnXgT3jA_1741707036
X-Mimecast-Originator: redhat.com
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit

On Tue, Mar 11, 2025 at 09:47:21AM +0800, Glass Su wrote:
> Right. I’ve considered the way making fs_last_byte zero/large enough as `btrfs filesystem resize ` can
> handle the newsize rightly. For me, it’s more like a quirk. If it’s acceptable to you I can provide a patchset to implement
> the logic, and a testcase, of course.

Sure, I can review that.

