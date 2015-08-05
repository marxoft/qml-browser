/*
 * Copyright (C) 2015 Stuart Howarth <showarth@marxoft.co.uk>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 3 as
 * published by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#ifndef ENCODINGMODEL_H
#define ENCODINGMODEL_H

#include "selectionmodel.h"

class EncodingModel : public SelectionModel
{
    Q_OBJECT
    
public:
    explicit EncodingModel(QObject *parent = 0) :
        SelectionModel(parent)
    {
        append(tr("Central European") + " (ISO 8859-2)", QString("ISO 8859-2"));
        append(tr("Central European") + " (Windows-1250)", QString("Windows-1250"));
        append(tr("Chinese, Simplified") + " (GB18030)", QString("GB18030"));
        append(tr("Chinese, Simplified") + " (ISO-2022-CN)", QString("ISO-2022-CN"));
        append(tr("Chinese, Traditional") + " (Big5 I/II)", QString("Big5"));
        append(tr("Chinese, Traditional") + " (EUC-TW)", QString("EUC-TW"));
        append(tr("Cyrillic") + " (KOI-8R)", QString("KOI-8R"));
        append(tr("Cryillic") + " (Windows-1251)", QString("Windows-1251"));
        append(tr("Greek") + " (ISO 8859-7)", QString("ISO 8859-7"));
        append(tr("Greek") + " (Windows-1253)", QString("Windows-1253"));
        append(tr("Latin") + " (ISO 8859-1)", QString("ISO 8859-1"));
        append(tr("Latin extended") + " (ISO 8859-15)", QString("ISO 8859-15"));
        append(tr("Turkish") + " (ISO 8859-9)", QString("ISO 8859-9"));
        append(tr("Turkish") + " (Windows-1254)", QString("Windows-1254"));
        append(tr("Unicode") + " (UTF-16)", QString("UTF-16"));
        append(tr("Unicode") + " (UTF-8)", QString("UTF-8"));
    }
};

#endif // ENCODINGMODEL_H
