import yaml
import json

import numpy as np
import pandas as pd

members_en = pd.read_csv('members.csv')
members_es = pd.read_csv('members_es.csv')
print(members_es)

class Person(object):
    """Member of the IUCN CSSG"""
    def __init__(self, last, first):
        super(Person, self).__init__()
        self.last = last
        self.first = first

        self.en = {}
        self.es = {}

        self.read_en_data()
        self.read_es_data()

    def row(self, df):
        """Integer for the row corresponding to the person in a dataframe"""
        return df[(df['last'] == self.last) & (df['first'] == self.first)].iloc[0]



    def read_en_data(self):
        """Read in english language data (may have overlap with spanish)"""
        data = self.row(members_en)
        self.en['country'] = '' if pd.isnull(data['country']) else data['country'].strip()
        self.en['city'] = '' if pd.isnull(data['city']) else data['city'].strip()
        self.en['region'] = '' if pd.isnull(data['region']) else data['region'].strip()
        self.en['email'] = '' if pd.isnull(data['email']) else data['email'].strip()
        self.en['position'] = '' if pd.isnull(data['position']) else data['position'].strip()
        self.en['image'] = '' if pd.isnull(data['image']) else data['image'].strip()
        self.en['institution'] = '' if pd.isnull(data['institution']) else data['institution'].strip()
        self.en['expertise'] = '' if pd.isnull(data['expertise']) else data['expertise'].strip()
        self.en['description'] = '' if pd.isnull(data['description']) else data['description'].strip()


    def read_es_data(self):
        """Read in spanish language data (may have overlap with english)"""
        data = self.row(members_es)
        self.es['country'] = '' if pd.isnull(data['country']) else data['country'].strip()
        self.es['city'] = '' if pd.isnull(data['city']) else data['city'].strip()
        self.es['region'] = '' if pd.isnull(data['region']) else data['region'].strip()
        self.es['email'] = '' if pd.isnull(data['email']) else data['email'].strip()
        self.es['position'] = '' if pd.isnull(data['position']) else data['position'].strip()
        self.es['image'] = '' if pd.isnull(data['image']) else data['image'].strip()
        self.es['institution'] = '' if pd.isnull(data['institution']) else data['institution'].strip()
        self.es['expertise'] = '' if pd.isnull(data['expertise']) else data['expertise'].strip()
        self.es['description'] = '' if pd.isnull(data['description']) else data['description'].strip()

    def as_dict(self):
        """Data encapuslated in a single dictionary"""
        return {
            'first': self.first,
            'last': self.last,
            'en': self.en,
            'es': self.es
        }

    def json(self):
        """JSON representation of the person's data"""
        return json.dumps(self.as_dict())

    def yaml(self):
        """YAML representation of the person's data"""
        return yaml.dump(self.as_dict())

def create_master_yaml():
    """Roll all members into single yaml file"""
    members = []
    for idx, row in members_en.iterrows():
        first, last = row['first'], row['last']
        try:
            members.append(Person(last, first).as_dict())
        except IndexError as e:
            print(f'{first} {last}')
            raise e
    members.sort(key = lambda p: (p['last'], p['first']))
    with open('members.yml', 'w') as f:
        f.write(yaml.dump(members))



if __name__ == '__main__':
    create_master_yaml()
        