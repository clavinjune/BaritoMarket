'use client';

import {
  Appbar,
  Nav,
  NavItem,
  NavItemIcon,
  NavItemCaption,
  NavLink,
} from "@asphalt-react/appbar"
import { Button } from '@asphalt-react/button';
import {
	Applications,
	Calculator,
	LogOut,
	Mugshot,
	Person,
} from "@asphalt-react/iconpack"
import { Logo } from "@asphalt-react/logo";
import { Modal } from "@asphalt-react/modal"
import { Search } from "@asphalt-react/textfield"
import { useEffect, useState } from "react";

export default function Wrapper({
	children,
}: Readonly<{
	children: React.ReactNode;
}>) {
	useEffect(() => {
		window.document.addEventListener('keyup', e => {
			if (e.key !== '/') {
				return
			}
			setOpen(true)
		})
	})
	const [isOpen, setOpen] = useState(false)
	const routes = [
		{
			href: '/users',
			caption: 'Users',
			icon: <Person />,
		},
		{
			href: '/groups',
			caption: 'Groups',
			icon: <Mugshot />,
		},
		{
			href: '/external-applications',
			caption: 'External Apps',
			icon: <Applications />,
		},
		{
			href: '/price-calculator',
			caption: 'Price Calculator',
			icon: <Calculator />,
		},
	]

	return <>
		<Modal
			open={isOpen}
			onClose={() => {
				setOpen(false)
			}}
		>
			<Search size="l" placeholder="Search..." />
		</Modal>
		<Appbar
			head={
				<Button link asProps={{href: "/"}} nude system size="s" underline={false}>
					<Logo product="Barito Log" symbol={false} size="m" />
				</Button>
			}
			tail={
				<Button nude system size="s" qualifier={<LogOut />}>
					Sign Out
				</Button>
			}
		>
			<Nav>
				{routes.map((r, i) => <NavItem key={i}>
					<NavLink asProps={{href: r.href}} active={i === 0}>
						<NavItemIcon>{r.icon}</NavItemIcon>
						<NavItemCaption>{r.caption}</NavItemCaption>
					</NavLink>
				</NavItem>)}
			</Nav>
		</Appbar>
		{children}
	</>
}
