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

#ifndef FONTSIZEMODEL_H
#define FONTSIZEMODEL_H

#include "selectionmodel.h"

class FontSizeModel : public SelectionModel
{
    Q_OBJECT
    
public:
    explicit FontSizeModel(QObject *parent = 0) :
        SelectionModel(parent)
    {
        append(tr("Normal"), 16);
        append(tr("Large"), 20);
        append(tr("Very large"), 24);
    }
};

#endif // FONTSIZEMODEL_H
