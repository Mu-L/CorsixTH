/*
Copyright (c) 2009 Peter "Corsix" Cawley

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

#include "frmSprites.h"

#include "config.h"

#include <wx/button.h>
#include <wx/chartype.h>
#include <wx/dcclient.h>
#include <wx/filedlg.h>
#include <wx/filefn.h>
#include <wx/gdicmn.h>
#include <wx/image.h>
#include <wx/msgdlg.h>
#include <wx/sizer.h>
#include <wx/stattext.h>
#include <wx/textctrl.h>
#include <wx/unichar.h>
#include <wx/utils.h>

BEGIN_EVENT_TABLE(frmSprites, wxFrame)
  EVT_BUTTON(ID_LOAD, frmSprites::_onLoad)
  EVT_BUTTON(ID_BROWSE_TABLE, frmSprites::_onBrowseTable)
  EVT_BUTTON(ID_BROWSE_DATA, frmSprites::_onBrowseData)
  EVT_BUTTON(ID_BROWSE_PALETTE, frmSprites::_onBrowsePalette)
  EVT_BUTTON(ID_LOAD_COMPLEX, frmSprites::_onLoadComplex)
  EVT_BUTTON(ID_NEXT, frmSprites::_onNext)
END_EVENT_TABLE()

frmSprites::frmSprites()
    : wxFrame(nullptr, wxID_ANY, L"Theme Hospital Sprite Viewer") {
  wxBoxSizer* pMainSizer = new wxBoxSizer(wxVERTICAL);

  wxStaticBoxSizer* pFiles = new wxStaticBoxSizer(wxVERTICAL, this, L"Files");
  wxFlexGridSizer* pFilesGrid = new wxFlexGridSizer(4, 3, 2, 1);
  pFilesGrid->AddGrowableCol(1, 1);
  pFilesGrid->Add(new wxStaticText(this, wxID_ANY, L"Table:"),
                  wxSizerFlags(0).Center().Right());
  m_txtTable = new wxTextCtrl(
      this, wxID_ANY, L"X:\\ThemeHospital\\hospital\\QData\\Font00V.tab");

  pFilesGrid->Add(m_txtTable,
                  wxSizerFlags(1).Align(wxALIGN_CENTER_VERTICAL).Expand());
  pFilesGrid->Add(new wxButton(this, ID_BROWSE_TABLE, L"Browse..."),
                  wxSizerFlags(0).Align(wxALIGN_CENTER_VERTICAL));
  pFilesGrid->Add(new wxStaticText(this, wxID_ANY, L"Data:"),
                  wxSizerFlags(0).Center().Right());
  m_txtData = new wxTextCtrl(this, wxID_ANY, L"");
  pFilesGrid->Add(m_txtData,
                  wxSizerFlags(1).Align(wxALIGN_CENTER_VERTICAL).Expand());
  pFilesGrid->Add(new wxButton(this, ID_BROWSE_DATA, L"Browse..."),
                  wxSizerFlags(0).Align(wxALIGN_CENTER_VERTICAL));
  pFilesGrid->Add(new wxStaticText(this, wxID_ANY, L"Palette:"),
                  wxSizerFlags(0).Center().Right());

  m_txtPalette = new wxTextCtrl(
      this, wxID_ANY, L"X:\\ThemeHospital\\hospital\\Data\\MPalette.dat");

  pFilesGrid->Add(m_txtPalette,
                  wxSizerFlags(1).Align(wxALIGN_CENTER_VERTICAL).Expand());
  pFilesGrid->Add(new wxButton(this, ID_BROWSE_PALETTE, L"Browse..."), 0,
                  wxALIGN_CENTER_VERTICAL);
  pFiles->Add(pFilesGrid, wxSizerFlags(0).Expand().Border(wxALL, 1));
  pFiles->Add(new wxButton(this, ID_LOAD, L"Load Simple"),
              wxSizerFlags(0).Center().Border(wxALL, 1));
  pFiles->Add(new wxButton(this, ID_LOAD_COMPLEX, L"Load Complex"),
              wxSizerFlags(0).Center().Border(wxALL, 1));
  pFiles->Add(new wxButton(this, ID_NEXT, L"Next"),
              wxSizerFlags(0).Center().Border(wxALL, 1));
  pMainSizer->Add(pFiles, wxSizerFlags(0).Expand().Border(wxALL, 2));

  wxStaticBoxSizer* pSprites =
      new wxStaticBoxSizer(wxVERTICAL, this, L"Sprites");
  m_panFrame = new MyVScrolled(this);
  pSprites->Add(m_panFrame, wxSizerFlags(1).Expand());
  pMainSizer->Add(pSprites, wxSizerFlags(1).Expand().Border(wxALL, 2));
  m_panFrame->Connect(wxEVT_PAINT,
                      (wxObjectEventFunction)&frmSprites::_onPanelPaint,
                      nullptr, this);

  SetSizer(pMainSizer);

  load(true);
}

void frmSprites::_onLoad(wxCommandEvent& evt) { load(false); }

void frmSprites::_onLoadComplex(wxCommandEvent& evt) { load(true); }

void frmSprites::_onNext(wxCommandEvent& evt) {
  wxString s = m_txtTable->GetValue();
  while (true) {
    const wxChar* sc = s.c_str();
    for (size_t i = s.Length(); i > 0;) {
      --i;
      if ('0' <= sc[i] && sc[i] <= '9') {
        s.SetChar(i, sc[i] + 1);
        if (sc[i] > '9') {
          s.SetChar(i, '0');
          if (sc[i - 1] == '9') {
            s.SetChar(i - 1, '0');
            return;
          }
          s.SetChar(i - 1, sc[i - 1] + 1);
        }
        break;
      }
    }
    if (::wxFileExists(s)) {
      m_txtTable->SetValue(s);
      return;
    }
  }
}

void frmSprites::load(bool bComplex) {
  if (!m_oAnims.loadTableFile(m_txtTable->GetValue()) ||
      !m_oAnims.loadSpriteFile(m_txtData->GetValue().IsEmpty()
                                   ? m_txtTable->GetValue().BeforeLast('.') +
                                         L".DAT"
                                   : m_txtData->GetValue()) ||
      !m_oAnims.loadPaletteFile(m_txtPalette->GetValue())) {
    ::wxMessageBox(L"Cannot load files");
    return;
  }

  m_vSprites.clear();
  for (size_t i = 0; i < m_oAnims.getSpriteCount(); ++i) {
    _sprite_t oSprite;
    Bitmap* pSpriteBitmap = m_oAnims.getSpriteBitmap(i, bComplex);
    oSprite.caption =
        wxString::Format(L"#%i (%ix%i)", (int)i, pSpriteBitmap->getWidth(),
                         pSpriteBitmap->getHeight());
    if (pSpriteBitmap->getWidth() * pSpriteBitmap->getHeight() > 0) {
      wxImage imgSprite(pSpriteBitmap->getWidth(), pSpriteBitmap->getHeight(),
                        false);
      pSpriteBitmap->blit(imgSprite, 0, 0, nullptr, m_oAnims.getPalette(),
                          0x8000);
      oSprite.bitmap = wxBitmap(imgSprite);
    }
    m_vSprites.push_back(oSprite);
  }

  m_panFrame->Refresh();
}

void frmSprites::_onPanelPaint(wxPaintEvent& evt) {
  wxPaintDC dc(m_panFrame);

  int iAvailableWidth, iAvailableHeight;
  m_panFrame->GetClientSize(&iAvailableWidth, &iAvailableHeight);
  int iX = 0;
  int iTallest = 0;
  int iTotal = 0;
  int iY = -m_panFrame->GetVisibleRowsBegin();

  for (std::vector<_sprite_t>::iterator itr = m_vSprites.begin(),
                                        itrEnd = m_vSprites.end();
       itr != itrEnd; ++itr) {
    wxSize szLabel = dc.GetTextExtent(itr->caption);
    int iWidth = wxMax(szLabel.GetWidth(),
                       itr->bitmap.IsOk() ? itr->bitmap.GetWidth() : 0);
    int iHeight = (itr->bitmap.IsOk() ? itr->bitmap.GetHeight() : 0) +
                  szLabel.GetHeight() + 2;
    if (iWidth + iX > iAvailableWidth) {
      iY += iTallest;
      iTotal += iTallest;
      iX = iTallest = 0;
    }

    if (iY + iHeight >= 0 && iY < iAvailableHeight) {
      dc.DrawText(itr->caption, iX, iY);
      if (itr->bitmap.IsOk())
        dc.DrawBitmap(itr->bitmap, iX, iY + szLabel.GetHeight() + 1);
    }

    iTallest = wxMax(iTallest, iHeight);
    iX += iWidth + 2;
  }

  iTotal += iTallest;  // Add last row too.

  // Update the row count if it doesn't match.
  if (iTotal != m_panFrame->iMyCount) {
    m_panFrame->iMyCount = iTotal;
    m_panFrame->SetRowCount(iTotal);
  }
}

// File type selection is by wildcards limited to ? or *, separated by ;
// https://docs.wxwidgets.org/trunk/classwx_file_dialog.html remarks section
void frmSprites::_onBrowseTable(wxCommandEvent& WXUNUSED(evt)) {
  m_txtTable->SetValue(::wxFileSelector(
      L"Select location of Font00V.tab (DATA)", m_txtTable->GetValue(),
      L"Font00V.tab", L"tab", L"Tab files (*.tab)|*.TAB;*.tab", 0, this));
}
void frmSprites::_onBrowseData(wxCommandEvent& WXUNUSED(evt)) {
  m_txtData->SetValue(::wxFileSelector(
      L"Choose Theme Hospital data file", m_txtData->GetValue(), L"", L"dat",
      L"DAT files (*.dat)|*.DAT;*.dat", 0, this));
}
void frmSprites::_onBrowsePalette(wxCommandEvent& WXUNUSED(evt)) {
  m_txtPalette->SetValue(::wxFileSelector(
      L"Select location of MPalette.dat (QDATA)", m_txtPalette->GetValue(),
      L"MPalette.dat", L"dat",
      L"Dat or Pal files (*.dat, *.pal)|*.DAT;*.dat;*.PAL;*.pal", 0, this));
}
