Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D525314A84
	for <lvm-devel@lists.linux.dev>; Mon, 23 Oct 2023 14:43:37 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=linuxfoundation.org header.i=@linuxfoundation.org header.b="mi3YvliS"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 357EDC433C8;
	Mon, 23 Oct 2023 14:43:37 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=linuxfoundation.org;
	s=korg; t=1698072217;
	bh=V4AgfFBYe/QbV+gbDuV9JmctWjPXi59nUYySxYJATC4=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=mi3YvliSzv12Yh2Qhsy2PSKOrfphptSGOdXi8G6a6xWC9faDUpk3rPy5Wxl9gGXym
	 kvnB+/m0Zpr0Uc6xutDmjhtZM6EFsFUwng9zqfHPt+Oa3RXrsXfR55csqijfAm+uk2
	 Fih/j3wH+bfQaVTT3XBh/RMS6r7P9yBnyn7I9DW8=
Date: Mon, 23 Oct 2023 10:43:36 -0400
From: Konstantin Ryabitsev <konstantin@linuxfoundation.org>
To: Mike Snitzer <snitzer@redhat.com>
Cc: lvm-devel@lists.linux.dev
Subject: Re: lvm-devel has migrated to lists.linux.dev [was: Re: Welcome to
 the "lvm-devel" mailing list]
Message-ID: <20231023-garland-defile-fa2dfa@meerkat>
References: <mailman.0.1697833396.3533474.lvm-devel@redhat.com>
 <ZTLybIL0gBcfDEe2@redhat.com>
Precedence: bulk
X-Mailing-List: lvm-devel@lists.linux.dev
List-Id: <lvm-devel.lists.linux.dev>
List-Subscribe: <mailto:lvm-devel+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:lvm-devel+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <ZTLybIL0gBcfDEe2@redhat.com>

On Fri, Oct 20, 2023 at 05:34:36PM -0400, Mike Snitzer wrote:
> The lvm-devel list archive will soon be migrating here:
> https://lore.kernel.org/lvm-devel/

This is now completed and the archives are available at the above address.

-K
