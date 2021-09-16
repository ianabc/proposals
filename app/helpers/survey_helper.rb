module SurveyHelper
  def citizenship_options
    citizenships = [%w[Afghanistan Afghanistan], %w[Albania Albania], %w[Algeria Algeria], %w[Andorra Andorra],
                    %w[Angola Angola], %w[Antigua Antigua], %w[Argentina Argentina],
                    %w[Armenia Armenia], %w[Australia Australia], %w[Austria Austria], %w[Azerbaijan Azerbaijan],
                    %w[Bahamas Bahamas], %w[Bahrain Bahrain], %w[Bangladesh Bangladesh], %w[Barbados Barbados],
                    %w[Barbuda Barbuda], %w[Belarus Belarus], %w[Belgium Belgium], %w[Belize Belize],
                    %w[Bhutan Bhutan], %w[Bolivia Bolivia], %w[Bosnia Bosnia], %w[Herzegovina Herzegovina],
                    %w[Botswana Botswana], %w[Brazil Brazil], %w[Brunei Brunei], %w[Bulgaria Bulgaria],
                    ['Burkina Faso', 'Burkina Faso'], %w[Burundi Burundi], ['Cabo Verde', 'Cabo Verde'],
                    %w[Cambodia Cambodia], %w[Cameroon Cameroon], %w[Canada Canada],
                    ['Central African Republic', 'Central African Republic'], %w[Chad Chad], %w[Chile Chile],
                    %w[China China], %w[Colombia Colombia], %w[Comoros Comoros],
                    ['Congo (Congo-Brazzaville)', 'Congo (Congo-Brazzaville)'], ['Costa Rica', 'Costa Rica'],
                    %w[Croatia Croatia], %w[Cuba Cuba], %w[Cyprus Cyprus],
                    ['Czechia (Czech Republic)', 'Czechia (Czech Republic)'],
                    ['Democratic Republic of the Congo', 'Democratic Republic of the Congo'],
                    %w[Denmark Denmark], %w[Djibouti Djibouti], %w[Dominica Dominica],
                    ['Dominican Republic', 'Dominican Republic'], %w[Ecuador Ecuador], %w[Egypt Egypt],
                    ['El Salvador', 'El Salvador'], ['Equatorial Guinea', 'Equatorial Guinea'],
                    %w[Eritrea Eritrea], %w[Estonia Estonia],
                    ['Eswatini (fmr. "Swaziland")', 'Eswatini (fmr. "Swaziland")'], %w[Ethiopia Ethiopia],
                    %w[Fiji Fiji], %w[Finland Finland], %w[France France], %w[Gabon Gabon], %w[Gambia Gambia],
                    %w[Georgia Georgia], %w[Germany Germany], %w[Ghana Ghana], %w[Greece Greece],
                    %w[Grenada Grenada], %w[Guatemala Guatemala], %w[Guinea Guinea],
                    %w[Guinea-Bissau Guinea-Bissau], %w[Guyana Guyana], %w[Haiti Haiti], ['Holy See', 'Holy See'],
                    %w[Honduras Honduras], %w[Hungary Hungary], %w[Iceland Iceland], %w[India India],
                    %w[Indonesia Indonesia], %w[Iran Iran], %w[Iraq Iraq], %w[Ireland Ireland], %w[Israel Israel],
                    %w[Italy Italy], %w[Jamaica Jamaica], %w[Japan Japan], %w[Jordan Jordan],
                    %w[Kazakhstan Kazakhstan], %w[Kenya Kenya], %w[Kiribati Kiribati], %w[Kuwait Kuwait],
                    %w[Kyrgyzstan Kyrgyzstan], %w[Laos Laos], %w[Latvia Latvia],
                    %w[Lebanon Lebanon], %w[Lesotho Lesotho], %w[Liberia Liberia], %w[Libya Libya],
                    %w[Liechtenstein Liechtenstein], %w[Lithuania Lithuania], %w[Luxembourg Luxembourg],
                    %w[Madagascar Madagascar], %w[Malawi Malawi], %w[Malaysia Malaysia], %w[Maldives Maldives],
                    %w[Mali Mali], %w[Malta Malta], %w[Marshall Islands Marshall Islands], %w[Mauritania Mauritania],
                    %w[Mauritius Mauritius], %w[Mexico Mexico], %w[Micronesia Micronesia],
                    %w[Moldova Moldova], %w[Monaco Monaco], %w[Mongolia Mongolia], %w[Montenegro Montenegro],
                    %w[Morocco Morocco], %w[Mozambique Mozambique],
                    ['Myanmar (formerly Burma)', 'Myanmar (formerly Burma)'], %w[Namibia Namibia], %w[Nauru Nauru],
                    %w[Nepal Nepal], %w[Netherlands Netherlands], ['New Zealand', 'New Zealand'],
                    %w[Nicaragua Nicaragua], %w[Niger Niger], %w[Nigeria Nigeria],
                    ['North Korea', 'North Korea'], ['North Macedonia', 'North Macedonia'], %w[Norway Norway],
                    %w[Oman Oman], %w[Pakistan Pakistan], %w[Palau Palau], ['Palestine State', 'Palestine State'],
                    %w[Panama Panama], ['Papua New Guinea', 'Papua New Guinea'], %w[Paraguay Paraguay],
                    %w[Peru Peru], %w[Philippines Philippines], %w[Poland Poland], %w[Portugal Portugal],
                    %w[Qatar Qatar], %w[Romania Romania], %w[Russia Russia], %w[Rwanda Rwanda],
                    ['Saint Kitts and Nevis', 'Saint Kitts and Nevis'], ['Saint Lucia', 'Saint Lucia'],
                    ['Saint Vincent and the Grenadines', 'Saint Vincent and the Grenadines'], %w[Samoa Samoa],
                    ['San Marino', 'San Marino'], ['Sao Tome and Principe', 'Sao Tome and Principe'],
                    ['Saudi Arabia', 'Saudi Arabia'], %w[Senegal Senegal],
                    %w[Serbia Serbia], %w[Seychelles Seychelles], ['Sierra Leone', 'Sierra Leone'],
                    %w[Singapore Singapore], %w[Slovakia Slovakia], %w[Slovenia Slovenia],
                    ['Solomon Islands', 'Solomon Islands'], %w[Somalia Somalia], ['South Africa', 'South Africa'],
                    ['South Korea', 'South Korea'], ['South Sudan', 'South Sudan'], %w[Spain Spain],
                    ['Sri Lanka', 'Sri Lanka'], %w[Sudan Sudan], %w[Suriname Suriname], %w[Sweden Sweden],
                    %w[Switzerland Switzerland], %w[Syria Syria], %w[Tajikistan Tajikistan], %w[Taiwan Taiwan],
                    %w[Tanzania Tanzania], %w[Thailand Thailand], %w[Timor-Leste Timor-Leste], %w[Togo Togo],
                    %w[Tonga Tonga], ['Trinidad and Tobago', 'Trinidad and Tobago'], %w[Tunisia Tunisia],
                    %w[Turkey Turkey], %w[Turkmenistan Turkmenistan], %w[Tuvalu Tuvalu],
                    %w[Uganda Uganda], %w[Ukraine Ukraine], ['United Arab Emirates', 'United Arab Emirates'],
                    ['United Kingdom', 'United Kingdom'], ['United States of America', 'United States of America'],
                    %w[Uruguay Uruguay], %w[Uzbekistan Uzbekistan], %w[Vanuatu Vanuatu], %w[Venezuela Venezuela],
                    %w[Vietnam Vietnam], %w[Yemen Yemen], %w[Zambia Zambia], %w[Zimbabwe Zimbabwe],
                    %w[Other Other], ['Prefer not to answer', 'Prefer not to answer']]
    citizenships.map { |disp, _value| disp }
  end

  def ethnicity_options
    ethnicity = [%w[Arab Arab], %w[Black Black], %w[Chinese Chinese], %w[Filipino Filipino],
                 ['Indigenous (within North America)', 'Indigenous (within North America)'],
                 %w[Japanese Japanese], %w[Korean Korean], ['Latin American', 'Latin American'],
                 ['South Asian (e.g., Indian, Pakistani, Sri Lankan)',
                  'South Asian (e.g., Indian, Pakistani, Sri Lankan)'],
                 ['Southeast Asian (e.g., Vietnamese, Cambodian, Laotian, Thai)',
                  'Southeast Asian (e.g., Vietnamese, Cambodian, Laotian, Thai)'],
                 ['West Asian (e.g., Iranian, Afghan)', 'West Asian (e.g., Iranian, Afghan)'],
                 %w[White White], %w[Other Other],
                 ['Prefer not to answer [Please note: If you choose this response, none of your other
                  responses to this question will be considered in the data analysis.]', 'Prefer not to answer']]
    ethnicity.map { |disp, _value| disp }
  end

  def gender_options
    gender = [%w[Woman Woman], %w[Man Man], ['Gender fluid and/or non-binary person',
                                             'Gender fluid and/or non-binary person'], %w[Other Other],
              ['Prefer not to answer', 'Prefer not to answer']]
    gender.map { |disp, _value| disp }
  end

  def indigenous_person_options
    indigenous = [%w[Yes Yes], %w[No No], ['Prefer not to answer', 'Prefer not to answer']]
    indigenous.map { |disp, _value| disp }
  end

  def indigenous_person_yes_options
    indigenous_yes = [['First Nation', 'First Nation'], %w[Métis Métis], %w[Inuit Inuit],
                      ['Native American', 'Native American'],
                      ['Indigenous from outside of what is now known as Canada and the United States',
                       'Indigenous from outside of what is now known as Canada and the United States'],
                      ['Prefer not to answer', 'Prefer not to answer']]
    indigenous_yes.map { |disp, _value| disp }
  end
end
