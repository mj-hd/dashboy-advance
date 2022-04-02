use std::io::{BufReader, Cursor};

use anyhow::{Context, Result};
use once_cell::sync::OnceCell;

use crate::{gba::Gba, keypad::KeyType, rom::Rom};

static mut GBA: OnceCell<Gba> = OnceCell::new();

pub fn load_rom(bytes: Vec<u8>) -> Result<()> {
    let mut reader = BufReader::new(Cursor::new(bytes));
    let rom = Box::new(Rom::new(&mut reader)?);

    unsafe { GBA.set(Gba::new(rom)) };

    Ok(())
}

pub fn reset(skip_bios: bool) -> Result<()> {
    unsafe {
        let gba = GBA.get_mut().context("reset failed to get gba")?;
        if skip_bios {
            gba.cpu.reset_skip_bios()?;
        } else {
            gba.cpu.reset()?;
        }
    }

    Ok(())
}

pub fn key_press(key: KeyType) -> Result<()> {
    unsafe {
        let gba = GBA.get_mut().context("p1 keydown failed to get nes")?;
        gba.cpu.bus.keypad.press(key);
    }
    Ok(())
}

pub fn key_release(key: KeyType) -> Result<()> {
    unsafe {
        let gba = GBA.get_mut().context("p1 keydown failed to get nes")?;
        gba.cpu.bus.keypad.release(key);
    }
    Ok(())
}

pub fn render() -> Result<Vec<u8>> {
    unsafe {
        let gba = GBA.get_mut().context("p1 keydown failed to get nes")?;
        for _ in 0..(16777216 / 32) {
            gba.tick().unwrap();
        }
        Ok(gba.cpu.bus.ppu.render())
    }
}
